/**
 * Firebase Cloud Functions untuk Dapur Mamma Admin
 * 
 * Deploy:
 * 1. Install Firebase CLI: npm install -g firebase-tools
 * 2. Login: firebase login
 * 3. Init functions: firebase init functions (pilih JavaScript)
 * 4. Copy isi file ini ke functions/index.js
 * 5. Deploy: firebase deploy --only functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const midtransClient = require('midtrans-client');
const crypto = require('crypto');

admin.initializeApp();

/**
 * Cloud Function untuk set Admin Role
 * Callable function yang bisa dipanggil dari app
 * 
 * Cara pakai dari Flutter:
 * final callable = FirebaseFunctions.instance.httpsCallable('setAdminRole');
 * await callable.call({'email': 'bayfrd24@gmail.com'});
 */
exports.setAdminRole = functions.https.onCall(async (data, context) => {
  // Hanya super admin yang bisa set admin role
  // Untuk pertama kali, comment pengecekan ini
  /*
  if (!context.auth || context.auth.token.superAdmin !== true) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Hanya Super Admin yang bisa menambah admin baru'
    );
  }
  */

  const email = data.email;
  if (!email) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Email harus diisi'
    );
  }

  try {
    // Dapatkan user by email
    const user = await admin.auth().getUserByEmail(email);

    // Set custom claim admin: true
    await admin.auth().setCustomUserClaims(user.uid, {
      admin: true,
    });

    return {
      success: true,
      message: `User ${email} berhasil dijadikan admin`,
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Cloud Function untuk hapus Admin Role
 */
exports.removeAdminRole = functions.https.onCall(async (data, context) => {
  // Hanya super admin yang bisa hapus admin role
  if (!context.auth || context.auth.token.admin !== true) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Tidak memiliki izin'
    );
  }

  const email = data.email;
  if (!email) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Email harus diisi'
    );
  }

  try {
    const user = await admin.auth().getUserByEmail(email);

    // Hapus custom claim
    await admin.auth().setCustomUserClaims(user.uid, {
      admin: false,
    });

    return {
      success: true,
      message: `Admin role untuk ${email} berhasil dihapus`,
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * HTTP Function untuk set admin (one-time setup)
 * Akses via browser: https://[region]-[project-id].cloudfunctions.net/setInitialAdmin?email=bayfrd24@gmail.com&secret=YOUR_SECRET_KEY
 * 
 * PENTING: Ganti YOUR_SECRET_KEY dengan key rahasia Anda
 * Hapus function ini setelah setup selesai!
 */
exports.setInitialAdmin = functions.https.onRequest(async (req, res) => {
  const SECRET_KEY = "dapurmamma2026"; // Ganti dengan key rahasia

  const email = req.query.email;
  const secret = req.query.secret;

  if (secret !== SECRET_KEY) {
    res.status(403).send("Forbidden: Invalid secret key");
    return;
  }

  if (!email) {
    res.status(400).send("Bad Request: Email is required");
    return;
  }

  try {
    const user = await admin.auth().getUserByEmail(email);
    await admin.auth().setCustomUserClaims(user.uid, { admin: true });

    res.status(200).send(`Success! ${email} is now an admin. Please delete this function after setup.`);
  } catch (error) {
    res.status(500).send(`Error: ${error.message}`);
  }
});

/**
 * Create Midtrans Snap Transaction
 * Callable function for Flutter app
 */
exports.createMidtransTransaction = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  const orderIdDoc = data.orderId; // Firestore Document ID
  if (!orderIdDoc) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing Order ID');
  }

  try {
    const orderRef = admin.firestore().collection('orders').doc(orderIdDoc);
    const orderDoc = await orderRef.get();

    if (!orderDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Order not found');
    }

    const orderData = orderDoc.data();

    // Inisialisasi Midtrans Client
    // PLACEHOLDER: Ganti dengan environment variable di produksi
    let snap = new midtransClient.Snap({
      isProduction: false,
      serverKey: 'YOUR_MIDTRANS_SERVER_KEY',
      clientKey: 'YOUR_MIDTRANS_CLIENT_KEY'
    });

    let parameter = {
      "transaction_details": {
        "order_id": orderData.orderId, // Human readable ID (e.g. ORD-00001)
        "gross_amount": orderData.total
      },
      "credit_card": {
        "secure": true
      },
      "customer_details": {
        "first_name": orderData.customerName,
        "email": context.auth.token.email
      },
      "item_details": orderData.items.map(item => ({
        "id": item.productId,
        "price": item.price,
        "quantity": item.quantity,
        "name": item.productName
      }))
    };

    const transaction = await snap.createTransaction(parameter);

    // Simpan token ke Firestore untuk track
    await orderRef.update({
      midtransSnapToken: transaction.token,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return {
      token: transaction.token,
      redirect_url: transaction.redirect_url
    };

  } catch (error) {
    console.error('Midtrans Error:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Midtrans Webhook (Notification Handler)
 * Terima POST dari Midtrans
 */
exports.midtransWebhook = functions.https.onRequest(async (req, res) => {
  const notificationJson = req.body;

  // PLACEHOLDER: Ganti dengan environment variable
  const serverKey = 'YOUR_MIDTRANS_SERVER_KEY';

  // KRITIS: Verifikasi Signature Key untuk keamanan
  const orderId = notificationJson.order_id;
  const statusCode = notificationJson.status_code;
  const grossAmount = notificationJson.gross_amount;
  const signatureKey = notificationJson.signature_key;

  const hash = crypto.createHash('sha512')
    .update(`${orderId}${statusCode}${grossAmount}${serverKey}`)
    .digest('hex');

  if (hash !== signatureKey) {
    console.error('CRITICAL: Invalid Midtrans Signature!');
    return res.status(403).send('Invalid signature');
  }

  const transactionStatus = notificationJson.transaction_status;
  const fraudStatus = notificationJson.fraud_status;

  console.log(`Transaction ID: ${notificationJson.transaction_id}, Order ID: ${orderId}, Status: ${transactionStatus}`);

  let appStatus = 'pending';

  if (transactionStatus == 'capture') {
    if (fraudStatus == 'challenge') {
      appStatus = 'pending';
    } else if (fraudStatus == 'accept') {
      appStatus = 'processing';
    }
  } else if (transactionStatus == 'settlement') {
    appStatus = 'processing';
  } else if (transactionStatus == 'cancel' || transactionStatus == 'deny' || transactionStatus == 'expire') {
    appStatus = 'cancelled';
  } else if (transactionStatus == 'pending') {
    appStatus = 'pending';
  }

  try {
    // Cari order berdasarkan orderId (bukan doc ID)
    const orderQuery = await admin.firestore().collection('orders')
      .where('orderId', '==', orderId)
      .limit(1)
      .get();

    if (orderQuery.empty) {
      console.error(`Order ${orderId} not found in Firestore`);
      return res.status(404).send('Order not found');
    }

    const orderDoc = orderQuery.docs[0];
    await orderDoc.ref.update({
      status: appStatus,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      paymentDetails: {
        transactionId: notificationJson.transaction_id,
        paymentType: notificationJson.payment_type,
        midtransStatus: transactionStatus,
        rawNotification: notificationJson
      }
    });

    return res.status(200).send('OK');
  } catch (error) {
    console.error('Webhook Error:', error);
    return res.status(500).send('Internal Server Error');
  }
});
