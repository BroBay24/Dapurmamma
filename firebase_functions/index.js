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
