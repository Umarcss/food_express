const admin = require("firebase-admin");
const {HttpsError, onCall} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");

admin.initializeApp();

const paystackSecretKey = defineSecret("PAYSTACK_SECRET_KEY");

function getPaystackSecretKey() {
  return paystackSecretKey.value() || process.env.PAYSTACK_SECRET_KEY;
}

function assertPaystackConfigured() {
  const secret = getPaystackSecretKey();
  if (!secret) {
    throw new HttpsError(
      "failed-precondition",
      "Paystack secret key is not configured.",
    );
  }
  return secret;
}

exports.initializePaystackPayment = onCall(
  {secrets: [paystackSecretKey]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in to pay for this order.");
    }

    const orderId = request.data && request.data.orderId;
    if (!orderId) {
      throw new HttpsError("invalid-argument", "orderId is required.");
    }

    const orderRef = admin.firestore().collection("orders").doc(orderId);
    const orderSnap = await orderRef.get();
    if (!orderSnap.exists) {
      throw new HttpsError("not-found", "Order was not found.");
    }

    const order = orderSnap.data();
    if (order.userId !== request.auth.uid) {
      throw new HttpsError("permission-denied", "This order is not yours.");
    }

    const secret = assertPaystackConfigured();
    const response = await fetch("https://api.paystack.co/transaction/initialize", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${secret}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: request.auth.token.email,
        amount: order.totalKobo,
        currency: "NGN",
        metadata: {orderId},
      }),
    });

    const payload = await response.json();
    if (!response.ok || !payload.status) {
      throw new HttpsError("internal", payload.message || "Paystack initialization failed.");
    }

    await orderRef.update({
      paymentStatus: "pending",
      paystackReference: payload.data.reference,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      accessCode: payload.data.access_code,
      reference: payload.data.reference,
    };
  },
);

exports.verifyPaystackPayment = onCall(
  {secrets: [paystackSecretKey]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign in to verify payment.");
    }

    const reference = request.data && request.data.reference;
    if (!reference) {
      throw new HttpsError("invalid-argument", "reference is required.");
    }

    const secret = assertPaystackConfigured();
    const response = await fetch(
      `https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`,
      {
        headers: {
          Authorization: `Bearer ${secret}`,
        },
      },
    );

    const payload = await response.json();
    if (!response.ok || !payload.status) {
      throw new HttpsError("internal", payload.message || "Paystack verification failed.");
    }

    const orderId = payload.data.metadata && payload.data.metadata.orderId;
    if (!orderId) {
      throw new HttpsError("failed-precondition", "Payment is missing order metadata.");
    }

    const orderRef = admin.firestore().collection("orders").doc(orderId);
    const orderSnap = await orderRef.get();
    if (!orderSnap.exists || orderSnap.data().userId !== request.auth.uid) {
      throw new HttpsError("permission-denied", "This payment cannot be verified for this user.");
    }

    const paid = payload.data.status === "success";
    await orderRef.update({
      paymentStatus: paid ? "paid" : "failed",
      status: paid ? "confirmed" : "pending",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {status: paid};
  },
);
