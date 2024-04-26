error:
	echo "use 'make install' or 'make uninstall'"

install: package
	kpackagetool6 --type=KWin/Script -i .

uninstall:
	kpackagetool6 --type=KWin/Script -r Walk-Through-Desktop
	qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.cleanUp

upgrade: package
	kpackagetool6 --type=KWin/Script -u .

test: package upgrade
	qdbus org.kde.KWin /KWin reconfigure
	kwin --replace & disown

package: clean
	zip -r walk-through-desktop.kwinscript contents metadata.json metadata.json.license README.md

clean:
	rm walk-through-desktop.kwinscript || echo "Already cleaned"

log:
	journalctl -f QT_CATEGORY=qml
