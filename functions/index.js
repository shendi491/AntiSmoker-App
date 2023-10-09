const functions = require("firebase-functions");
const {initializeApp, applicationDefault, cert} =
    require("firebase-admin/app");
const {getFirestore, Timestamp, FieldValue, Filter} =
    require("firebase-admin/firestore");
const admin = require("firebase-admin");
admin.initializeApp();
const fcm = admin.messaging();

exports.sendNotificationSmoke = functions.firestore
    .document("detected/{detectedID}")
    .onCreate(async (snap, context) => {
      const newData = snap.data();
      const db = getFirestore();
      const tokens = [];
      const fetchTokens = await db.collection("tokens")
          .get();

      fetchTokens.docs.forEach(async (doc) =>{
        const token = doc.data().fcm_tokens;
        functions.logger.info(`tokennya ${token}`);
        tokens.push(token);
      });
      const payload = {
        notification: {
          title: "Ada Perokok !!!",
          body: `Terdeteksi asap di bilik ${newData.bilik}`,
          sound: "default",
          channel_id: "SMOKE",
          android_channel_id: "smoke",
          priority: "high",
        },
      };
      try {
        tokens.forEach(async (val) =>{
          const response = await fcm.sendToDevice(val, payload);
          functions.logger.info(response.results);
        });
      } catch (error) {
        functions.logger.info(error);
      }
    });
