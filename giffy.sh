#!/bin/bash

# GIF Widget for KDE Plasma 6 - Automated Installer
# Run this script to install the widget

set -e

WIDGET_ID="com.github.giffy"
WIDGET_DIR="$HOME/.local/share/plasma/plasmoids/$WIDGET_ID"

echo "================================================"
echo "  GIF Widget for KDE Plasma 6 - Installer"
echo "================================================"
echo ""

# Create directories
echo "Creating directories..."
mkdir -p "$WIDGET_DIR/contents/ui"
mkdir -p "$WIDGET_DIR/contents/config"

# Create main.qml
echo "Creating main.qml..."
cat > "$WIDGET_DIR/contents/ui/main.qml" << 'MAINQML'
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    width: Kirigami.Units.gridUnit * 15
    height: Kirigami.Units.gridUnit * 15
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
    
    property string gifPath: plasmoid.configuration.gifPath || "/path/to/your/image.gif"
    property bool showBorder: plasmoid.configuration.showBorder || false
    
    preferredRepresentation: fullRepresentation
    
    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 5
        Layout.minimumHeight: Kirigami.Units.gridUnit * 5
        Layout.preferredWidth: Kirigami.Units.gridUnit * 15
        Layout.preferredHeight: Kirigami.Units.gridUnit * 15
        
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: showBorder ? Kirigami.Theme.highlightColor : "transparent"
            border.width: 2
            radius: Kirigami.Units.cornerRadius
            
            AnimatedImage {
                id: gifImage
                anchors.fill: parent
                anchors.margins: 5
                source: gifPath.startsWith("file://") ? gifPath : "file://" + gifPath
                fillMode: Image.PreserveAspectFit
                playing: true
                cache: false
                
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.8
                    height: parent.height * 0.8
                    color: Kirigami.Theme.backgroundColor
                    opacity: 0.8
                    radius: Kirigami.Units.cornerRadius
                    visible: gifImage.status === Image.Error || gifImage.status === Image.Null
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Kirigami.Units.smallSpacing
                        
                        Kirigami.Icon {
                            source: "image-missing"
                            Layout.preferredWidth: Kirigami.Units.iconSizes.huge
                            Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                            Layout.alignment: Qt.AlignHCenter
                        }
                        
                        Text {
                            text: "GIF not found\n\nRight-click to configure"
                            color: Kirigami.Theme.textColor
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: Kirigami.Units.gridUnit * 0.8
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
                
                Rectangle {
                    anchors.centerIn: parent
                    width: Kirigami.Units.gridUnit * 3
                    height: Kirigami.Units.gridUnit * 3
                    color: Kirigami.Theme.backgroundColor
                    opacity: 0.8
                    radius: Kirigami.Units.cornerRadius
                    visible: gifImage.status === Image.Loading
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Loading..."
                        color: Kirigami.Theme.textColor
                    }
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            
            onClicked: {
                gifImage.playing = !gifImage.playing
            }
        }
    }
    
    compactRepresentation: Item {
        Kirigami.Icon {
            anchors.fill: parent
            source: "image-gif"
            active: compactMouse.containsMouse
        }
        
        MouseArea {
            id: compactMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
        }
    }
}
MAINQML

# Create metadata.json
echo "Creating metadata.json..."
cat > "$WIDGET_DIR/metadata.json" << 'METADATA'
{
    "KPlugin": {
        "Authors": [
            {
                "Name": "Kibble"
            },
            {
                "Name": "Claude Sonnet 4.5"
            }
        ],
        "Category": "Multimedia",
        "Description": "Display an animated GIF on your desktop",
        "Icon": "image-gif",
        "Id": "com.github.giffy",
        "License": "GPL-2.0+",
        "Name": "Giffy",
        "Version": "2.0",
        "Website": "https://github.com/KibbleCode/giffy-kde6-plasmoid"
    },
    "KPackageStructure": "Plasma/Applet",
    "X-Plasma-API-Minimum-Version": "6.0"
}
METADATA

# Create main.xml
echo "Creating main.xml..."
cat > "$WIDGET_DIR/contents/config/main.xml" << 'MAINXML'
<?xml version="1.0" encoding="UTF-8"?>
<kcfg xmlns="http://www.kde.org/standards/kcfg/1.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.kde.org/standards/kcfg/1.0
      http://www.kde.org/standards/kcfg/1.0/kcfg.xsd">
  <kcfgfile name=""/>
  <group name="General">
    <entry name="gifPath" type="String">
      <default>/path/to/your/image.gif</default>
    </entry>
    <entry name="showBorder" type="Bool">
      <default>false</default>
    </entry>
  </group>
</kcfg>
MAINXML

# Create config.qml
echo "Creating config.qml..."
cat > "$WIDGET_DIR/contents/config/config.qml" << 'CONFIGQML'
import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "configure"
        source: "configGeneral.qml"
    }
}
CONFIGQML

# Create configGeneral.qml
echo "Creating configGeneral.qml..."
cat > "$WIDGET_DIR/contents/ui/configGeneral.qml" << 'CONFIGGENERAL'
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_gifPath: gifPathField.text
    property alias cfg_showBorder: showBorderCheck.checked

    Kirigami.FormLayout {
        QQC2.TextField {
            id: gifPathField
            Kirigami.FormData.label: "GIF Path:"
            placeholderText: "/path/to/your/image.gif"
            Layout.fillWidth: true
        }
        
        QQC2.Button {
            text: "Browse..."
            icon.name: "document-open"
            onClicked: fileDialog.open()
        }
        
        QQC2.CheckBox {
            id: showBorderCheck
            text: "Show border"
            Kirigami.FormData.label: "Appearance:"
        }
        
        Item {
            Kirigami.FormData.isSection: true
        }
        
        QQC2.Label {
            text: "Click the widget to pause/play the animation"
            font.italic: true
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }
    
    FileDialog {
        id: fileDialog
        title: "Select GIF file"
        nameFilters: ["GIF images (*.gif)", "All files (*)"]
        onAccepted: {
            gifPathField.text = selectedFile.toString().replace("file://", "")
        }
    }
}
CONFIGGENERAL

echo ""
echo "✅ All files created!"
echo ""
echo "🔄 Restarting Plasma Shell..."
sleep 2

if systemctl --user is-active --quiet plasma-plasmashell.service; then
    systemctl --user restart plasma-plasmashell.service
else
    killall plasmashell 2>/dev/null
    sleep 1
    plasmashell &>/dev/null &
fi

echo ""
echo "================================================"
echo "  ✨ Installation Complete! ✨"
echo "================================================"
echo ""
echo "Next Steps:"
echo "1. Right-click desktop → 'Add Widgets'"
echo "2. Search for 'Giffy'"
echo "3. Add it to your desktop"
echo "4. Right-click widget → Configure → Browse for your GIF"
echo ""
echo "To uninstall: rm -rf $WIDGET_DIR"
echo ""
