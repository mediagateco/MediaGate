const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
// The Firebase Admin SDK to access the Firebase Realtime Database.
//const admin = require('firebase-admin');
//admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//


 // exports.helloWorld = functions.https.onRequest((request, response) => {
 //  response.send("Hello from Firebase!");
 // });
// exports.sendPushNotification = functions.https.onRequest((request, response) => {
//  response.send("Attempting to send push notifications");
//  console.log("LOGGER — —  Trying to send push message..");
//  //var uid= 'OROqmwX33XGNBy6YoPNo'
//  var fcmToken = 'd535KJkR3k__sOjUk0-auJ:APA91bGfwbC82e5SK4gi8LaoRtJl934NlpSJLaYJW9MHi9vfiRHbUQpzcWpVpwLjdvgz0RZtlQRfxud7RU5TNuu4IDQd_KvV2P4mJJSnyDAy72K0CSqyGB4lODNsxR8f1ndK3QvEh8_C'
//  //return admin.firestore().collection('Users').doc(uid).get().then(snapshot => {
//   // var user = snapshot.data();
//    //console.log("user ID from firestore " + user.userID );
//    var payload = {
//      notification: {
//        title:  'Push Notification Title',
//        body: 'Test notification message'
//      }
//    }
//    return admin.messaging().sendToDevice(fcmToken, payload)
//      .then(function(response) {
//        console.log('Successfully sent message: ', response);
//          })
//          .catch(function(error) {
//        console.log('Error sending message:', error);
//          });
// // })
// })

// exports.observeLike = functions.firestore
//        .document('Likes/{DocumentID}')
//        .onCreate((snap,context) => {
//
//        console.log("LOGGER — —  Trying to send push message that a like has been created..");
//        var fcmToken = 'fxXr59VoekIkpm_50bgh-D:APA91bERhjSNSUnqt0TVgaZ6qdqmz_Deu_oA_brZ1QApyzF1baLQ69Vdev_8AgyuqRuXO3Hbh7j5aCtMshkNAtVTCtjPH1FqH6DP-DV7qpPE1_sUFnxNE1_IW46a7dQk0Za9LtkMdhOB'
//
//
//           var payload = {
//             notification: {
//               title:  'Push Notification for Likes',
//               body: 'This is a notification message that a like has been added'
//             }
//           }
//     return admin.messaging().sendToDevice(fcmToken, payload)
//         .then(function(response) {
//             console.log("Successfully sent message:", response);
//         })
//         .catch(function(error) {
//             console.log("Error sending message:", error);
//         });
//
// })

exports.observeLikeFCM = functions.firestore
       .document('Likes/{LikedById}')
       .onCreate((snap,context) => {

       var likedById = context.params.LikedById;
       const likeId = snap.data();
       const likedBy = likeId.LikedById;
       const likedDocumentId = likeId.DocumentID;

       console.log("LOGGER — —  Trying to send push message that a like has been created..");

       return admin.firestore()
       .collection('Posts')
       .doc(likedDocumentId)
       .get().then(queryResult => {
         const post = queryResult.data()
         const userId = post.postedById
         //console.log("user Email is from firestore " + user.fcmToken );
         return admin.firestore()
         .collection('Users')
         .doc(userId)
         .get().then(res => {
            const user = res.data()
            return admin.firestore()
            .collection('Users')
            .doc(likedBy)
            .get().then(result => {
               const liker = result.data()
               var payload = {
                 notification: {
                   title:  'إعجاب جديد',
                   body: ' لديك إعجاب جديد من' + ' ' + liker.Name,
                   sound: 'default'
                 }
               }
               admin.messaging().sendToDevice(user.fcmToken, payload)
               .then(function(response) {
                 console.log("Successfully sent message:", response);
               })
               .catch(function(error) {
                 console.log("Error sending message:", error);
               })
            })
         })
      });
})
