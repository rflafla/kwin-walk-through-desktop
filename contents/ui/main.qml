import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kwin
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore


PlasmaCore.Dialog {
    id: mainDialog
    visible: false
    title: "Test switch"

    type: PlasmaCore.Dialog.OnScreenDisplay
    // backgroundHints: PlasmaCore.Types.NoBackground
    // flags: Qt.X11BypassWindowManagerHint | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Popup
    // flags: Qt.Popup
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    property var desktops: []
    property var indexCurrent: 0

    function toggle() {
        if (mainDialog.visible) {
            hide();
        } else {
            show();
        }
    }

    function display(info) {
        console.info('-----------');
        console.info(info);
        for (var key in info) {
            console.info(key, info[key]);
        }

        for (var key in info.prototype) {
            console.info(key, info.prototype[key]);
        }
        console.info('-----------');
    }

    function show() {
        // console.info('display');
        try {
            mainDialog.indexCurrent = 0;

            mainItem.width = mainDialog.desktops.length * 100;
            desktopRepeater.model = mainDialog.desktops;

            mainDialog.visible = true;
        } catch (e) {
            console.info(e);
        }

    }

    function hide() {
        mainDialog.visible = false;
        // console.info('hide');

        updateOrder();
    }

    function displayOrder() {
        for (var d of mainDialog.desktops) {
            console.info(d.name);
        }
    }

    function next() {
        try {
            // console.info('next');
            mainDialog.indexCurrent++;
            if (mainDialog.indexCurrent >= mainDialog.desktops.length) {
                mainDialog.indexCurrent = 0;
            }
            // console.info('goto ', mainDialog.indexCurrent);
            Workspace.currentDesktop = mainDialog.desktops[mainDialog.indexCurrent];
        } catch (e) {
            console.info(e);
        }
    }

    function previous() {
        try {
            // console.info('previous');
            mainDialog.indexCurrent--;
            if (mainDialog.indexCurrent < 0) {
                mainDialog.indexCurrent = mainDialog.desktops.length - 1;
            }
            // console.info('goto ', mainDialog.indexCurrent);
            Workspace.currentDesktop = mainDialog.desktops[mainDialog.indexCurrent];
        } catch (e) {
            console.info(e);
        }
    }

    function initialize() {
        mainDialog.desktops = Array.from(Workspace.desktops);
        updateOrder();
    }

    function updateOrder() {
        try {
            var i = desktops.indexOf(Workspace.currentDesktop);
            // console.info('Swap with', i);
            if (i > 0) {
                var current = mainDialog.desktops[i];
                // console.info('current', current);
                mainDialog.desktops.splice(i, 1);
                mainDialog.desktops.splice(0, 0, current);
            }
            // displayOrder();
        } catch (e) {
            console.info(e);
        }
    }

    function changed(desktop) {
        try {
            if (!mainDialog.visible) {
                updateOrder();
            } else {
                // console.info('No update');
            }
        } catch (e) {
            console.info(e);
        }
    }

    Item {
        id: shortcuts

        ShortcutHandler {
            id: mainShortcut
            name: "Walk Through Desktop"
            text: "Walk Through Desktop"
            sequence: "Meta+Tab"
            onActivated: {
                if (!mainDialog.visible) {
                    show();
                }
                next();
            }
        }

        ShortcutHandler {
            id: mainShortcutReverse
            name: "Walk Through Desktop (reverse)"
            text: "Walk Through Desktop (reverse)"
            sequence: "Meta+Shift+Tab"
            onActivated: {
                if (!mainDialog.visible) {
                    show();
                }
                previous();
            }
        }
    }
    Item {
        id: mainItem
        focus: true
        Keys.onEscapePressed: (event) => {
            // console.info('onEscapePressed', event);
            hide();
        }
        Keys.onReleased: (event) => {
            // console.info('onReleased key', event.key);
            // console.info('onReleased modifiers', event.modifiers);
            // 16777250 : meta
            // 16777217 : tab
            if (event.modifiers === 0 || event.key !== 16777217) {
                hide();
            }
        }

        Connections {
            target: Workspace
            function onCurrentDesktopChanged(desktop) {
                try {
                    // console.info('desktop changed', desktop);
                    // display(desktop);
                    changed(desktop);
                    // displayOrder();
                } catch (e) {
                    console.info(e);
                }
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
                }
            }
        }

    }

    Component.onCompleted: {
        initialize();
    }
}
