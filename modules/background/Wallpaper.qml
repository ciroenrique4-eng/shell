pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.components.filedialog
import qs.components.images
import qs.services
import qs.utils

Item {
    id: root

    property string source: Wallpapers.current
    property Item current: one
    property bool completed

    onSourceChanged: {
        if (!source)
            current = null;
        else if (current === one)
            two.update();
        else
            one.update();
    }

    Component.onCompleted: {
        if (source)
            Qt.callLater(() => {
                one.update();
                completed = true;
            });
    }

    Loader {
        asynchronous: true
        anchors.fill: parent

        active: root.completed && !root.source

        sourceComponent: StyledRect {
            color: Colours.palette.m3surfaceContainer

            Row {
                anchors.centerIn: parent
                spacing: Tokens.spacing.large

                MaterialIcon {
                    text: "sentiment_stressed"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Tokens.font.size.extraLarge * 5
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Tokens.spacing.small

                    StyledText {
                        text: qsTr("Wallpaper missing?")
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Tokens.font.size.extraLarge * 2
                        font.bold: true
                    }

                    StyledRect {
                        implicitWidth: selectWallText.implicitWidth + Tokens.padding.large * 2
                        implicitHeight: selectWallText.implicitHeight + Tokens.padding.small * 2

                        radius: Tokens.rounding.full
                        color: Colours.palette.m3primary

                        FileDialog {
                            id: dialog

                            title: qsTr("Select a wallpaper")
                            filterLabel: qsTr("Image files")
                            filters: Images.validImageExtensions
                            onAccepted: path => Wallpapers.setWallpaper(path)
                        }

                        StateLayer {
                            radius: parent.radius
                            color: Colours.palette.m3onPrimary
                            onClicked: dialog.open()
                        }

                        StyledText {
                            id: selectWallText

                            anchors.centerIn: parent

                            text: qsTr("Set it now!")
                            color: Colours.palette.m3onPrimary
                            font.pointSize: Tokens.font.size.large
                        }
                    }
                }
            }
        }
    }

    ImgWrapper {
        id: one
    }

    ImgWrapper {
        id: two
    }

    component ImgWrapper: Item {
        id: wrapper

        function update(): void {
            if (path === root.source)
                root.current = this;
            else
                path = root.source;
        }

        property string path: ""
        readonly property bool isGif: path.endsWith(".gif")

        anchors.fill: parent
        opacity: 0
        scale: Wallpapers.showPreview ? 1 : 0.8

        CachingImage {
            id: staticImg
            anchors.fill: parent
            path: wrapper.path
            visible: !wrapper.isGif && wrapper.path !== ""

            onStatusChanged: {
                if (status === Image.Ready)
                    root.current = wrapper;
            }
        }

        Loader {
            id: gifLoader
            anchors.fill: parent
            active: wrapper.isGif && wrapper.path !== ""

            sourceComponent: AnimatedImage {
                source: wrapper.path
                playing: root.current === wrapper

                Component.onCompleted: {
                    root.current = wrapper;
                }
            }
        }

        states: State {
            name: "visible"
            when: root.current === wrapper

            PropertyChanges {
                wrapper.opacity: 1
                wrapper.scale: 1
            }
        }

        transitions: Transition {
            Anim {
                target: wrapper
                properties: "opacity,scale"
            }
        }
    }
}
