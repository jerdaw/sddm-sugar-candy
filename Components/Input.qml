//
// This file is part of SDDM Sugar Candy.
// A theme for the Simple Display Desktop Manager.
//
// Copyright (C) 2018–2020 Marian Arlt
//
// SDDM Sugar Candy is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation, either version 3 of the License, or any later version.
//
// You are required to preserve this and any additional legal notices, either
// contained in this file or in other files that you received along with
// SDDM Sugar Candy that refer to the author(s) in accordance with
// sections §4, §5 and specifically §7b of the GNU General Public License.
//
// SDDM Sugar Candy is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SDDM Sugar Candy. If not, see <https://www.gnu.org/licenses/>
//

import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0

Column {
    id: inputContainer
    Layout.fillWidth: true

    property Control exposeSession: sessionSelect.exposeSession
    property bool failed

    Item {
        id: usernameField

        height: root.font.pointSize * 4.5
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        TextField {
            id: username
            //text: config.ForceLastUser == "true" ? selectUser.currentText : null
            text: "Jer"
            font.capitalization: config.AllowBadUsernames == "false" ? Font.Capitalize : Font.MixedCase
            anchors.centerIn: parent
            height: root.font.pointSize * 3
            width: parent.width
            placeholderText: config.TranslatePlaceholderUsername || textConstants.userName
            selectByMouse: true
            horizontalAlignment: TextInput.AlignHCenter
            renderType: Text.QtRendering
            onFocusChanged:{
                if(focus)
                    selectAll()
            }
            background: Rectangle {
                color: "transparent"
                border.color: root.palette.text
                border.width: parent.activeFocus ? 2 : 1
                radius: config.RoundCorners || 0
            }
            onAccepted: loginButton.clicked()
            KeyNavigation.down: password
            z: 1

            states: [
                State {
                    name: "focused"
                    when: username.activeFocus
                    PropertyChanges {
                        target: username.background
                        border.color: root.palette.highlight
                    }
                    PropertyChanges {
                        target: username
                        color: root.palette.highlight
                    }
                }
            ]
        }

    }

    Item {
        id: passwordField
        height: root.font.pointSize * 4.5
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        // Set the focus on the password field when the component is completed
        Component.onCompleted: {
            password.forceActiveFocus();
        }

        TextField {
            id: password
            anchors.centerIn: parent
            height: root.font.pointSize * 3
            width: parent.width
            focus: config.ForcePasswordFocus == "true" ? true : false
            selectByMouse: true
            echoMode: TextInput.Password
            placeholderText: config.TranslatePlaceholderPassword || ""
            horizontalAlignment: TextInput.AlignHCenter
            passwordCharacter: "•"
            passwordMaskDelay: config.ForceHideCompletePassword == "true" ? undefined : 1000
            renderType: Text.QtRendering
            background: Rectangle {
                color: "transparent"
                border.color: root.palette.text
                border.width: parent.activeFocus ? 2 : 1
                radius: config.RoundCorners || 0
            }

            // Handler to trigger login on Enter key press
            onAccepted: {
                if (config.AllowEmptyPassword == "true" || username.text != "" && password.text != "") {
                    config.AllowBadUsernames == "false" ? sddm.login(username.text.toLowerCase(), password.text, sessionSelect.selectedSession) : sddm.login(username.text, password.text, sessionSelect.selectedSession);
                }
            }

            KeyNavigation.down: sessionSelect.exposeSession
        }

        states: [
            State {
                name: "focused"
                when: password.activeFocus
                PropertyChanges {
                    target: password.background
                    border.color: root.palette.highlight
                }
                PropertyChanges {
                    target: password
                    color: root.palette.highlight
                }
            }
        ]

        transitions: [
            Transition {
                PropertyAnimation {
                    properties: "color, border.color"
                    duration: 150
                }
            }
        ]
    }

    SessionButton {
        id: sessionSelect
        textConstantSession: textConstants.session
        loginButtonWidth: loginButton.background.width
    }

    Item { Layout.fillHeight: true }

    Item {
        height: root.font.pointSize * 4.3
        width: parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        Label {
            id: errorMessage
            width: parent.width
            text: failed ? config.TranslateLoginFailedWarning || textConstants.loginFailed + "!" : keyboard.capsLock ? config.TranslateCapslockWarning || textConstants.capslockWarning : null
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVBottom
            font.pointSize: root.font.pointSize * 1.25
            font.italic: true
            color: root.palette.text
            opacity: 0
            states: [
                State {
                    name: "fail"
                    when: failed
                    PropertyChanges {
                        target: errorMessage
                        opacity: 1
                        font.pointSize: root.font.pointSize * 1.25
                        color: "#bf616a"
                    }
                },
                State {
                    name: "capslock"
                    when: keyboard.capsLock
                    PropertyChanges {
                        target: errorMessage
                        opacity: 1
                    }
                }
            ]
            transitions: [
                Transition {
                    PropertyAnimation {
                        properties: "opacity"
                        duration: 100
                    }
                }
            ]
        }
    }

    Connections {
        target: sddm
        onLoginSucceeded: {}
        onLoginFailed: {
            failed = true
            resetError.running ? resetError.stop() && resetError.start() : resetError.start()
        }
    }

    Timer {
        id: resetError
        interval: 60000
        onTriggered: failed = false
        running: false
    }
}
