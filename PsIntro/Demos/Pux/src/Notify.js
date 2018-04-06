"use strict";

exports.show = function (text) {
    // soll ein Effekt werden
    return function () {

        if (!("Notification" in window)) {
            alert("This browser does not support desktop notification");
        }

        else if (Notification.permission === "granted") {
            var notification = new Notification(text);
        }

        else if (Notification.permission !== "denied") {
            Notification.requestPermission(function (permission) {
                if (permission === "granted") {
                    var notification = new Notification(text);
                }
            });
        }
    }
}