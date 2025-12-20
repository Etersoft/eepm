#!/bin/sh -x

# It will be run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"
PRODUCT=softmaker-freeoffice
PRODUCTDIR=/opt/softmaker-freeoffice

. $(dirname $0)/common.sh

remove_file $PRODUCTDIR/add_rpm_repo.sh

add_requires coreutils file gawk grep sed xprop
#use_system_xdg $PRODUCTDIR/mime/xdg-utils
remove_dir $PRODUCTDIR/mime/xdg-utils

cat <<EOF | create_file /usr/share/applications/$PRODUCT-planmaker.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Type=Application
GenericName=Spreadsheet
GenericName[am]=ሠንጠረዥ አስሊ
GenericName[ar]=جدول
GenericName[az]=Hesab Cədvəli
GenericName[bg]=Електронна таблица
GenericName[bn]=স্প্রেডশিট
GenericName[bs]=Spreadsheet
GenericName[ca]=Full de càlcul
GenericName[cs]=Tabulkový kalkulátor
GenericName[da]=Regneark
GenericName[de]=Tabellenkalkulation
GenericName[dz]=ཤོག་ཁྲམ།
GenericName[el]=Λογιστικό φύλλο
GenericName[en_CA]=Spreadsheet
GenericName[en_GB]=Spreadsheet
GenericName[en_ZA]=Spreadsheet
GenericName[es]=Hoja de cálculo
GenericName[et]=Arvutustabel
GenericName[eu]=Kalkulu-orria
GenericName[fi]=Taulukkolaskenta
GenericName[fil]=Spreadsheet
GenericName[fr]=Tableur
GenericName[ga]=Scarbhileog
GenericName[gl]=Folla de cálculo
GenericName[gu]=સ્પ્રેડશીટ
GenericName[he]=גיליון עבודה
GenericName[hr]=Proračunska tablica
GenericName[hu]=Táblázatkezelő
GenericName[is]=Töflureiknir
GenericName[it]=Foglio di calcolo
GenericName[ja]=スプレッドシート
GenericName[ka]=ელცხრილი
GenericName[ko]=스프레드시트
GenericName[ku]=Tabloya Hesêb
GenericName[mk]=Табели
GenericName[ms]=Hamparan
GenericName[nb]=Regneark
GenericName[ne]=स्प्रेडसिट
GenericName[nl]=Rekenblad
GenericName[nr]=Spredtjhiti
GenericName[nso]=Letlakala la go ala tsebišo
GenericName[oc]=Fuelha de calcul
GenericName[pa]=ਸਾਰਣੀ
GenericName[pl]=Arkusz kalkulacyjny
GenericName[pt]=Folha de Cálculo
GenericName[pt_BR]=Planilha Eletrônica
GenericName[ru]=Электронная таблица
GenericName[rw]=Urupapurorusesuye
GenericName[sk]=Tabuľka
GenericName[sq]=Fleta elektronike
GenericName[sr]=Табеле
GenericName[sr@Latn]=Tabele
GenericName[st]=Leqephe la ho ala boitsebiso
GenericName[sv]=Kalkylark
GenericName[th]=ตารางคำนวน
GenericName[tl]=Spreadsheet
GenericName[tr]=Hesap Çizelgesi
GenericName[ts]=Xipredxiti
GenericName[uk]=Електронні таблиці
GenericName[vi]=Bảng tính
GenericName[wa]=Tåvleu
GenericName[xh]=Icwecwe leeseli
GenericName[zh_CN]=电子表格
GenericName[zh_TW]=試算表
GenericName[zu]=Ispredshit
Comment=PlanMaker lets you create all kinds of spreadsheets -- from simple ones to the most complex ones. Includes a high-caliber charting module.
Comment[de]=Mit PlanMaker können Sie alle Arten von Arbeitsblättern erstellen -- von ganz einfachen bis zu den komplexesten. Inklusive eines leistungsstarken Diagrammmoduls.
Terminal=false
Categories=Application;Office;Spreadsheet
MimeType=application/x-pmd;application/x-pmv;application/excel;application/x-excel;application/x-ms-excel;application/x-msexcel;application/x-sylk;application/x-xls;application/xls;application/vnd.ms-excel;application/vnd.stardivision.calc;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;application/vnd.ms-excel.sheet.macroenabled.12;application/vnd.openxmlformats-officedocument.spreadsheetml.template;application/vnd.ms-excel.template.macroenabled.12;
Name=FreeOffice PlanMaker
Icon=pml
TryExec=planmaker
Exec=planmaker %F
StartupWMClass=pm
EOF

cat <<EOF | create_file /usr/share/applications/$PRODUCT-textmaker.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Type=Application
GenericName=Word Processor
GenericName[am]=ጽሁፍ አቀናጅ
GenericName[ar]=معالج نصوص
GenericName[az]=Kəlmə İşlədici
GenericName[bg]=Текстообработка
GenericName[bn]=ওয়ার্ড প্রসেসর
GenericName[bs]=Word Processor
GenericName[ca]=Processador de textos
GenericName[cs]=Textový procesor
GenericName[da]=Tekstbehandler
GenericName[de]=Textverarbeitung
GenericName[dz]=ཡིག་སྦྱོར་པ།
GenericName[el]=Επεξεργαστής κειμένου
GenericName[en_CA]=Word Processor
GenericName[en_GB]=Word Processor
GenericName[en_ZA]=Word Processor
GenericName[es]=Procesador de textos
GenericName[et]=Kirjutaja
GenericName[eu]=Testu-prozesadorea
GenericName[fi]=Tekstinkäsittely
GenericName[fil]=Tagaproseso ng Salita
GenericName[fr]=Traitement de texte
GenericName[ga]=Próiseálaithe Focal
GenericName[gl]=Procesador de textos
GenericName[gu]=વર્ડ પ્રોસેસર
GenericName[he]=מעבד תמלילים
GenericName[hr]=Obrada teksta
GenericName[hu]=Szövegszerkesztő
GenericName[is]=Ritvinnsla
GenericName[it]=Word processor
GenericName[ja]=ワープロ
GenericName[ka]=ტექსტის რედაქტორი
GenericName[ko]=워드 프로세서
GenericName[ku]=Bernameya nivîsandinê
GenericName[mk]=Процесор за текст
GenericName[ms]=Pemproses Perkataan
GenericName[nb]=Tekstbehandling
GenericName[ne]=शब्द प्रशोधक
GenericName[nl]=Tekstverwerker
GenericName[nr]=Isenzi Mitlolo
GenericName[nso]=Sehlami sa Lentšu
GenericName[oc]=Tractament de tèxt
GenericName[pa]=ਸ਼ਬਦਕਾਰ
GenericName[pl]=Edytor tekstu
GenericName[pt]=Processador de Texto
GenericName[pt_BR]=Editor de texto
GenericName[ru]=Редактор текстов
GenericName[sk]=Textový editor
GenericName[sq]=Procesues teksti
GenericName[sr]=Обрада текста
GenericName[sr@Latn]=Obrada teksta
GenericName[st]=Word Processor
GenericName[sv]=Ordbehandlare
GenericName[th]=พิมพ์งาน
GenericName[tl]=Tagaproseso ng Salita
GenericName[tr]=Kelime İşlemci
GenericName[ts]=Xitirhisi xa marito
GenericName[uk]=Текстовий процесор
GenericName[vi]=Bộ xử lý từ
GenericName[wa]=Aspougneu d' tecse
GenericName[xh]=Inkqubo Yokuqhuba Amagama
GenericName[zh_CN]=文字处理
GenericName[zh_TW]=文書處理器
GenericName[zu]=Umshini Ohlela Amagama
Comment=The TextMaker word processor lets you work on any type of document.
Comment[de]=Die Textverarbeitung TextMaker ermöglicht es Ihnen, beliebige Arten von Dokumenten zu erstellen und zu bearbeiten.
Terminal=false
Categories=Application;Office;WordProcessor
MimeType=application/x-tmd;application/x-tmv;application/msword;application/vnd.ms-word;application/x-doc;text/rtf;application/rtf;application/rtf;application/vnd.oasis.opendocument.text;application/vnd.oasis.opendocument.text-template;application/vnd.stardivision.writer;application/vnd.sun.xml.writer;application/vnd.sun.xml.writer.template;application/vnd.openxmlformats-officedocument.wordprocessingml.document;application/vnd.ms-word.document.macroenabled.12;application/vnd.openxmlformats-officedocument.wordprocessingml.template;application/vnd.ms-word.template.macroenabled.12;application/x-pocket-word;
Name=FreeOffice TextMaker
Icon=tml
TryExec=textmaker
Exec=textmaker %F
StartupWMClass=tm
EOF

cat <<EOF | create_file /usr/share/applications/$PRODUCT-presentations.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Type=Application
GenericName=Presentation
GenericName[am]=ትዕይንት
GenericName[az]=Təqdimat
GenericName[bg]=Презентация
GenericName[bn]=প্রেজেন্টেশন
GenericName[bs]=Prezentacija
GenericName[ca]=Presentació
GenericName[cs]=Prezentace
GenericName[da]=Præsentation
GenericName[de]=Präsentation
GenericName[dz]=གསལ་སྟོན།
GenericName[el]=Παρουσίαση
GenericName[en_CA]=Presentation
GenericName[en_GB]=Presentation
GenericName[en_ZA]=Presentation
GenericName[es]=Presentación
GenericName[et]=Esitlus
GenericName[eu]=Aurkezpena
GenericName[fi]=Esitys
GenericName[fil]=Pagtatanghal
GenericName[fr]=Présentation
GenericName[ga]=Toirbeathas
GenericName[gl]=Presentación
GenericName[gu]=રજૂઆત
GenericName[he]=מצגות
GenericName[hr]=Prezentacija
GenericName[hu]=Bemutatókészítő
GenericName[is]=Impress framsetning
GenericName[it]=Presentazione
GenericName[ja]=プレゼンテーション
GenericName[ka]=პრეზენტაცია
GenericName[ko]=프리젠테이션
GenericName[ku]=Pêşkêşî
GenericName[mk]=Презентација
GenericName[ms]=Persembahan
GenericName[nb]=Presentasjon
GenericName[ne]=प्रस्तुति
GenericName[nl]=Presentatie
GenericName[nr]=Phrizentheyitjhini
GenericName[nso]=Tlhagišo
GenericName[oc]=Presentacion
GenericName[pa]=ਪੇਸ਼ਕਾਰੀ
GenericName[pl]=Prezentacja
GenericName[pt]=Apresentação
GenericName[pt_BR]=Apresentação
GenericName[ru]=Презентация
GenericName[rw]=Iyerekana
GenericName[sk]=Prezentácia
GenericName[sq]=Prezantime
GenericName[sr]=Презентација
GenericName[sr@Latn]=Prezentacija
GenericName[st]=Nehelano
GenericName[sv]=Presentation
GenericName[th]=งานนำเสนอ
GenericName[tl]=Pagtatanghal
GenericName[tr]=Sunum
GenericName[ts]=Nkombiso
GenericName[uk]=Презентації
GenericName[vi]=Trình diễn
GenericName[wa]=Prezintåcion
GenericName[xh]=Umboniso wenkcazelo
GenericName[zh_CN]=演示文稿
GenericName[zh_TW]=簡報
GenericName[zu]=Iprezenteyshin
Comment=The SoftMaker Presentations software lets you design any kind of presentation - even including special effects, animations, and transitions.
Comment[de]=SoftMaker Presentations lässt Sie beliebige Präsentationen gestalten - mit Effekten, Animationen und Transitionen.
Terminal=false
Categories=Application;Office;Presentation
MimeType=application/x-prd;application/x-prv;application/x-prs;application/ppt;application/mspowerpoint;application/vnd.ms-powerpoint;application/vnd.openxmlformats-officedocument.presentationml.presentation;application/vnd.ms-powerpoint.presentation.macroenabled.12;application/vnd.openxmlformats-officedocument.presentationml.template;application/vnd.ms-powerpoint.template.macroenabled.12;application/vnd.ms-powerpoint.slideshow.macroEnabled.12;application/vnd.openxmlformats-officedocument.presentationml.slideshow;
Name=FreeOffice Presentations
Icon=prl
TryExec=presentations
Exec=presentations %F
StartupWMClass=pr
EOF

cd $BUILDROOT$PRODUCTDIR || fatal

VERSION_YEAR=$(ls mime | grep -oP 'softmaker-freeoffice\K[0-9]+' | head -n1 )

epm install --skip-installed xdg-utils

# as in desktop files
for i in 16 24 32 48 64 128 256 512 1024 ; do
    for app in prl tml pml ; do
        install_file icons/${app}_$i.png /usr/share/icons/hicolor/${i}x${i}/apps/"$app.png"
    done
done

# TODO: improve mime associations, icons

install_mimetypes_icon()
{
    local size="$1"
    shift
    local app="$1"
    shift

    local v
    for v in $* ; do
        install_file icons/${app}_$size.png /usr/share/icons/$THEME/${size}x${size}/mimetypes/$v.png
    done
}

for i in 48 16 32 64 128 ; do
    install_mimetypes_icon $i tmd application-x-tmd application-x-tmv

# app='tmd_mso'
#                    for VAR in application-rtf text-rtf application-msword application-msword-template application-vnd.ms-word application-x-doc application-x-pocket-word application-vnd.openxmlformats-officedocument.wordprocessingml.document application-vnd.openxmlformats-officedocument.wordprocessingml.template application-vnd.ms-word.document.macroenabled.12 application-vnd.ms-word.template.macroenabled.12 ; do
# app='tmd_oth'
#                    for VAR in application-x-pocket-word application-vnd.oasis.opendocument.text text-rtf application-vnd.sun.xml.writer application-vnd.sun.xml.writer.template application-vnd.wordperfect application-vnd.oasis.open

    install_mimetypes_icon $i pmd application-x-pmd application-x-pmv application-x-pmdx application/x-pagemaker

# app='pmd_mso'
#                    for VAR in application-x-sylk application-excel application-x-excel application-x-ms-excel application-x-msexcel application-x-xls application-xls application-vnd.ms-excel application-vnd.openxmlformats-officedocument.spreadsheetml.sheet application-vnd.openxmlformats-officedocument.spreadsheetml.template application-vnd.ms-excel.sheet.macroenabled.12 application-vnd.ms-excel.template.macroenabled.12 text-spreadsheet ; do
# app='pmd_oth'
#                    for VAR in text-csv application-x-dif application-x-prn application-vnd.stardivision.calc ; do

    install_mimetypes_icon $i prd application-x-prd application-x-prs application-x-prv

# app='prd_mso'
#                    for VAR in application-ppt application-mspowerpoint application-vnd.ms-powerpoint application-vnd.ms-powerpoint.presentation.macroenabled.12 application-vnd.ms-powerpoint.slideshow.macroEnabled.12 application-vnd.openxmlformats-officedocument.presentationml.presentation application-vnd.openxmlformats-officedocument.presentationml.template application-vnd.openxmlformats-officedocument.presentationml.slideshow ; do
done

# CHECKME
install_file $PRODUCTDIR/mime/$PRODUCT$VERSION_YEAR.xml /usr/share/mime/application/$PRODUCT$VERSION_YEAR.xml
install_file $PRODUCTDIR/mime/$PRODUCT$VERSION_YEAR.mime /usr/share/mime-info/$PRODUCT$VERSION_YEAR.mime

