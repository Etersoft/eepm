function __eepm_complete_repos
    if epm print info -s | grep -q alt
        echo basealt altsp yandex autoimports autoports altlinuxclub deferred deferred.org etersoft korinf archive URL
    end
end

function __eepm_list_commands
    string split '|' query q info packages filelist qp grep query_package ql get-files changelog cl qi show qa list-installed ls li list-available programs requires deplist depends req depends-on whatdepends rdepends whatrequires wd required-by provides prov whatprovides conflicts policy resolve qf wp which belongs install Install reinstall add i it installed simulate prescription recipe rm del remove delete uninstall erase purge e autoorphans remove-orphans update full-upgrade Upgrade upgrade update-repo ur up search search-file s find sr filesearch sf status list assure repo autoremove package-cleanup mark tool print addrepo ar repofix removerepo remove-repo rr check fix verify dedup release-upgrade upgrade-release upgrade-system release-switch history checkpkg integrity Downgrade release-downgrade downgrade-release downgrade-system downgrade distro-sync download fetch fc remove-old-kernels remove-old-kernel kernel-update kernel-upgrade update-kernel upgrade-kernel stats clean delete-cache dc restore audit site url ei ik epminstall epm-install selfinstall repack play pack | sort -u
end

function __eepm_list_installed_packages
    epm list --installed --quiet --short --direct
end

function __eepm_list_available_packages
    set -l cur (commandline -ct)
    if string match -q -r '^\.{0,2}/' -- $cur
        __fish_complete_path "$cur"
    else
        epm list --available --quiet --short --direct | grep "^$cur"
    end
end

function __eepm_list_available_kernels
    epm list --available --quiet --short --direct | grep 'kernel-image-' \
        | sed 's/kernel-image-//' \
        | grep "^$cur"
end


function __eepm_list_available_play
    epm play --list-all --quiet --short
end

function __eepm_complete_repack
    __fish_complete_path (commandline -ct)
end

function __eepm_complete_qf
    set -l cur (commandline -ct)
    if string match -qr '/' -- $cur
        __fish_complete_path $cur
    else
        complete -C "$cur"
    end
end

function __eepm_complete_repos
    if epm print info -s | grep -q alt
        printf '%s\n' basealt altsp yandex autoimports autoports altlinuxclub deferred deferred.org etersoft korinf archive URL
    end
end
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from addrepo ar removerepo rr' -xa '(__eepm_complete_repos)'
complete -c epm -c eepm -c upm -f -n  "__fish_seen_subcommand_from repo; and __fish_seen_subcommand_from change set add Add enable disable" -xa '(__eepm_complete_repos)'

complete -c epm -c eepm -c upm -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -f -a '(__eepm_list_available_kernels)'

complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s A -d "Include external module"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s D -d "Exclude external module"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s l -l list -d "List available kernels"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s h -l help -d "Show help"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s a -l all -d "Select all modules"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s i -l interactive -d "Interactive selection"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s H -l headers -d "Install kernel headers"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -l debuginfo -d "Install debuginfo package"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s f -s y -l force -d "Force upgrade"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s t -l type -d "Kernel flavor (std-def, std-kvm, etc)"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s r -l release -d "Kernel release"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s u -l update -d "Run apt-get update"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s n -l dry-run -d "Simulation mode"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from kernel-update kernel-upgrade update-kernel upgrade-kernel' -s d -l download-only -d "Download only"


complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from history' -s h -l help -d "Show help"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from history' -l installed -d "Show installed history"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from history' -l removed -d "Show removed history"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from history' -l updated -d "Show updated history"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from history' -l list -d "List all entries"


complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from status' -l installed -d "Check if installed"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from status' -l installable -d "Check if installable"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from status' -l original -d "Check if from distro"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from status' -l certified -d "Check certification"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from status' -l thirdparty -d "Check if third-party"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from status' -l repacked -d "Check if repacked"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from status' -l validate -d "Validate package"


complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from full-upgrade' -s h -l help -d "Show help"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from full-upgrade' -l interactive -d "Interactive mode"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from full-upgrade' -l ipfs -d "Use IPFS for epm play"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from full-upgrade' -l no-epm-play -d "Skip epm play"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from full-upgrade' -l no-flatpak -d "Skip flatpak"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from full-upgrade' -l no-snap -d "Skip snap"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from full-upgrade' -l no-kernel-update -d "Skip kernel update"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from full-upgrade' -l no-clean -d "Skip cleaning"


complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from list' -l available -d "Show available"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from list' -l installed -d "Show installed"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from list' -l upgradable -d "Show upgradable"

function __fish_mark_no_subcommand
    not __fish_seen_subcommand_from hold unhold showhold checkhold auto remove manual install showauto showmanual
end

complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from mark; and __fish_mark_no_subcommand' -a 'hold' -d "Mark package as held"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from mark; and __fish_mark_no_subcommand' -a 'unhold' -d "Unmark held package"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from mark; and __fish_mark_no_subcommand' -a 'showhold' -d "Show held packages"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from mark; and __fish_mark_no_subcommand' -a 'checkhold' -d "Check hold status"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from mark; and __fish_mark_no_subcommand' -a 'auto' -d "Mark as auto-installed"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from mark; and __fish_mark_no_subcommand' -a 'remove' -d "Mark for removal"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from mark; and __fish_mark_no_subcommand' -a 'manual' -d "Mark as manual"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from mark; and __fish_mark_no_subcommand' -a 'install' -d "Mark for installation"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from mark; and __fish_mark_no_subcommand' -a 'showauto' -d "Show auto-installed"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from mark; and __fish_mark_no_subcommand' -a 'showmanual' -d "Show manual packages"


function __fish_repo_no_subcommand
    not __fish_seen_subcommand_from list change set switch enable disable addkey clean save restore reset status add Add rm del remove create index pkgadd pkgupdate
end

complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'list' -d "List repos"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'change' -d "Change mirror"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'set' -d "Set mirror"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'switch' -d "Switch repo"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'enable' -d "Enable repo"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'disable' -d "Disable repo"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'addkey' -d "Add GPG key"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'clean' -d "Clean temp repos"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'save' -d "Save sources"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'restore' -d "Restore sources"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'reset' -d "Reset to default"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'status' -d "Repo status"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'add' -d "Add repo"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'Add' -d "Add repo and update"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'rm' -d "Remove repo"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'del' -d "Remove repo"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'remove' -d "Remove repo"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'create' -d "Create repo"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'index' -d "Index repo"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'pkgadd' -d "Add package"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from repo; and __fish_repo_no_subcommand' -a 'pkgupdate' -d "Update package"

complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -l auto -d "Non-interactive"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -l assumeyes -d "Assume yes"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -l non-interactive -d "Disable prompts"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -l help -d "Show help"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -l direct -d "Direct removal"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -a 'libs' -d "Remove libraries"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -a 'libs-devel' -d "Remove dev libs"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -a 'i586-libs' -d "Remove i586 libs"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -a 'debuginfo' -d "Remove debuginfo"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -a 'devel' -d "Remove dev packages"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -a 'python' -d "Remove Python"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -a 'python2' -d "Remove Python2"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -a 'python3' -d "Remove Python3"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -a 'perl' -d "Remove Perl"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -a 'gem' -d "Remove Gems"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from autoremove package-cleanup' -a 'ruby' -d "Remove Ruby"


complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l remove -d "Remove play package"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l update -d "Update play package"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l latest -d "Force latest version"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l list -d "List play packages"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l list-all -d "List all available"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l list-scripts -d "List package scripts"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l short -d "Short format"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l installed -d "List installed"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l ipfs -d "Use IPFS for download"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l product-alternatives -d "Show alternatives"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l quiet -d "Quiet mode"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l inscript -d "Script mode"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l interactive -d "Interactive mode"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from play' -l install -d "Install mode"


complete -c epmp -f -l remove -d "Remove play package"
complete -c epmp -f -l update -d "Update play package"
complete -c epmp -f -l latest -d "Force latest version"
complete -c epmp -f -l list -d "List play packages"
complete -c epmp -f -l list-all -d "List all available"
complete -c epmp -f -l list-scripts -d "List package scripts"
complete -c epmp -f -l short -d "Short format"
complete -c epmp -f -l installed -d "List installed"
complete -c epmp -f -l ipfs -d "Use IPFS for download"
complete -c epmp -f -l product-alternatives -d "Show alternatives"
complete -c epmp -f -l quiet -d "Quiet mode"
complete -c epmp -f -l inscript -d "Script mode"
complete -c epmp -f -l interactive -d "Interactive mode"
complete -c epmp -f -l install -d "Install mode"


complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from qa ls packages list-installed li' -l sort -d "list package(s) by size, most"
complete -c epm -c eepm -c upm -f -n '__fish_seen_subcommand_from qa ls packages list-installed li' -l last -d "list package(s) by latest installed"

complete -c epmqa -f -l sort -d "list package(s) by size, most"
complete -c epmqa -f -l last -d "list package(s) by latest installed"


complete -c epm -c eepm -c upm -f
complete -c epm -c eepm -c upm -n 'not __fish_seen_subcommand_from (__eepm_list_commands)' \
    -a '(__eepm_list_commands)'

complete -c epm -c eepm -c upm -s h -l help -d "Show help"
complete -c epm -c eepm -c upm -s v -l version -d "Show version"
complete -c epm -c eepm -c upm -l verbose -d "Verbose output"
complete -c epm -c eepm -c upm -l debug -d "Debug mode"
complete -c epm -c eepm -c upm -l skip-installed -d "Skip installed"
complete -c epm -c eepm -c upm -l skip-missed -d "Skip missed"
complete -c epm -c eepm -c upm -l show-command-only -d "Show command only"
complete -c epm -c eepm -c upm -l quiet -d "Quiet mode"
complete -c epm -c eepm -c upm -l silent -d "Silent mode"
complete -c epm -c eepm -c upm -l nodeps -d "Ignore dependencies"
complete -c epm -c eepm -c upm -l force -d "Force operation"
complete -c epm -c eepm -c upm -l noremove -d "No remove"
complete -c epm -c eepm -c upm -l no-stdin -d "No stdin"
complete -c epm -c eepm -c upm -l inscript -d "Script mode"
complete -c epm -c eepm -c upm -l dry-run -d "Simulate"
complete -c epm -c eepm -c upm -l simulate -d "Simulate"
complete -c epm -c eepm -c upm -l just-print -d "Just print"
complete -c epm -c eepm -c upm -l no-act -d "No action"
complete -c epm -c eepm -c upm -l short -d "Short output"
complete -c epm -c eepm -c upm -l direct -d "Direct mode"
complete -c epm -c eepm -c upm -l repack -d "Repack packages"
complete -c epm -c eepm -c upm -l norepack -d "No repack"
complete -c epm -c eepm -c upm -l install -d "Install mode"
complete -c epm -c eepm -c upm -l scripts -d "Run scripts"
complete -c epm -c eepm -c upm -l noscripts -d "No scripts"
complete -c epm -c eepm -c upm -l save-only -d "Save only"
complete -c epm -c eepm -c upm -l put-to-repo -d "Put to repo"
complete -c epm -c eepm -c upm -l download-only -d "Download only"
complete -c epm -c eepm -c upm -l url -d "URL mode"
complete -c epm -c eepm -c upm -l sort -d "Sort output"
complete -c epm -c eepm -c upm -l auto -d "Auto mode"
complete -c epm -c eepm -c upm -l assumeyes -d "Assume yes"
complete -c epm -c eepm -c upm -l non-interactive -d "Non-interactive"
complete -c epm -c eepm -c upm -l disable-interactivity -d "Disable prompts"
complete -c epm -c eepm -c upm -l interactive -d "Interactive"
complete -c epm -c eepm -c upm -l force-yes -d "Force yes"
complete -c epm -c eepm -c upm -l add-repo -d "Add repo"
complete -c epm -c eepm -c upm -l orphans -d "Handle orphans"

complete -c epm -c eepm -c upm -n '__fish_seen_subcommand_from install Install reinstall add i it installed' -f -a '(__eepm_list_available_packages)'
complete -c epmi -f -a '(__eepm_list_available_packages)'
complete -c epmI -f -a '(__eepm_list_available_packages)'

complete -c epm -c eepm -c upm -n '__fish_seen_subcommand_from rm del remove delete uninstall erase purge e autoorphans remove-orphans' -f -a '(__eepm_list_installed_packages)'
complete -c epme -f -a '(__eepm_list_installed_packages)'

complete -c epm -c eepm -c upm -n '__fish_seen_subcommand_from play' -f -a '(__eepm_list_available_play)'
complete -c epmp -f -a '(__eepm_list_available_play)'

complete -c epmwd -f -a '(__eepm_list_available_packages)'
complete -c epmcl -f -a '(__eepm_list_available_packages)'
complete -c epmqp -f -a '(__eepm_list_available_packages)'
complete -c epmql -f -a '(__eepm_list_available_packages)'
complete -c epmqa -f
complete -c epmqf -f -a '(__eepm_complete_qf)'
