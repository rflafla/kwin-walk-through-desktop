import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kwin
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore

// TODO l10n
// TODO number of the desktop instead of its name -> config
// TODO use sequence instead of hard-coded tab key
// FIXME pb when all keys are released at the same time
PlasmaCore.Dialog {
    id: mainDialog
    visible: false
    title: "Walk Through Desktops"

    type: PlasmaCore.Dialog.OnScreenDisplay
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    flags: Qt.X11BypassWindowManagerHint | Qt.FramelessWindowHint | Qt.Popup
    location: PlasmaCore.Types.Floating

    property var desktops: []
    property var indexCurrent: 0
    property var displayed: false

    function toggle() {
        if (mainDialog.visible) {
            hide();
        } else {
            show();
        }
    }

    function ensureDisplayed() {
        if (!mainDialog.displayed) {
            mainDialog.indexCurrent = 0;
            desktopRepeater.model = mainDialog.desktops;
            mainDialog.displayed = true;
        }
    }

    function show() {
        mainItem.width = mainDialog.desktops.length * 100;

        var screen = Workspace.clientArea(KWin.FullScreenArea, Workspace.activeScreen, Workspace.currentDesktop);
        mainDialog.visible = true;
        mainDialog.x = screen.x + screen.width/2 - mainDialog.width/2;
        mainDialog.y = screen.y + screen.height/2 - mainDialog.height/2;

        timer.interval = KWin.readConfig("timeDisappear", 1000);
        timer.running = false;
        timer.running = true;
    }

    function hide() {
        mainDialog.displayed = false;
        mainDialog.visible = false;
        timer.running = false;

        updateOrder();
    }

    function next() {
        mainDialog.indexCurrent++;
        if (mainDialog.indexCurrent >= mainDialog.desktops.length) {
            mainDialog.indexCurrent = 0;
        }
        Workspace.currentDesktop = mainDialog.desktops[mainDialog.indexCurrent];
    }

    function previous() {
        mainDialog.indexCurrent--;
        if (mainDialog.indexCurrent < 0) {
            mainDialog.indexCurrent = mainDialog.desktops.length - 1;
        }
        Workspace.currentDesktop = mainDialog.desktops[mainDialog.indexCurrent];

    }

    function initialize() {
        mainDialog.desktops = Array.from(Workspace.desktops);
        updateOrder();
    }

    function updateOrder() {
        var i = desktops.indexOf(Workspace.currentDesktop);
        if (i > 0) {
            var current = mainDialog.desktops[i];
            mainDialog.desktops.splice(i, 1);
            mainDialog.desktops.splice(0, 0, current);
        }
    }

    function changed(desktop) {
        if (!mainDialog.displayed) {
            updateOrder();
        }
    }

    function gotoDesktop(desktop) {
        Workspace.currentDesktop = desktop;
    }

    Item {
        id: shortcuts

        ShortcutHandler {
            id: mainShortcut
            name: "Walk Through Desktop"
            text: "Walk Through Desktop"
            sequence: "Meta+Tab"
            onActivated: info => {
                /*if (!mainDialog.displayed) {
                    //show();
                    mainDialog.indexCurrent = 0;
                }*/
                mainDialog.ensureDisplayed();
                next();
                show();
            }
        }

        ShortcutHandler {
            id: mainShortcutReverse
            name: "Walk Through Desktop (reverse)"
            text: "Walk Through Desktop (reverse)"
            sequence: "Meta+Shift+Tab"
            onActivated: {
                /*if (!mainDialog.displayed) {
                    //show();
                    mainDialog.indexCurrent = 0;
                }*/
                mainDialog.ensureDisplayed();
                previous();
                show();
            }
        }
    }
    Item {
        id: mainItem
        focus: true

        Timer {
            id: timer
            /*interval: 1000*/
            running: false
            repeat: false
            onTriggered: {
                hide();
            }
        }

        Keys.onEscapePressed: (event) => {
            hide();
        }
        Keys.onReleased: (event) => {
            // mainShortcut.sequence
            if (event.modifiers === 0 || (event.key !== Qt.Key_Tab && event.key !== Qt.Key_Backtab)) {
                hide();
            }
        }

        Connections {
            target: Workspace
            function onCurrentDesktopChanged(desktop) {
                changed(desktop);
            }

            function onDesktopsChanged() {
                initialize();
            }
        }

        height: 100
        width: 100

        Row {
            Repeater {
                id: desktopRepeater
                model: 0

                Rectangle {
                    id: rowElt
                    width: 100
                    height: 100
                    border.color: Kirigami.ColorUtils.tintWithAlpha(color, Kirigami.Theme.textColor, 0.2)
                    color: {
                        if (rowElt.index === mainDialog.indexCurrent) {
                            return Qt.rgba(Kirigami.Theme.hoverColor.r, Kirigami.Theme.hoverColor.g, Kirigami.Theme.hoverColor.b, 0.1);
                        }
                        return Kirigami.ColorUtils.tintWithAlpha(Kirigami.Theme.backgroundColor, Qt.rgba(0, 0, 0), 0.1);
                    }
                    required property int index
                    Text {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: 100
                        height: 100
                        color: Kirigami.Theme.textColor
                        text: mainDialog.desktops[rowElt.index].name + ''

                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            gotoDesktop(mainDialog.desktops[rowElt.index]);
                            hide();
                        }
                    }
                }
            }
        }

    }

    Component.onCompleted: {
        initialize();
        KWin.registerWindow(dialog);
    }
}
