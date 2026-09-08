"""Run the nouveau prescription with mocked commands and isolated config files."""

import os
import sys
from pathlib import Path
import subprocess
import tempfile

recipe_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent / 'prescription.d'
source = (recipe_dir / 'switch-to-nouveau.sh').read_text()
cases = ['success', 'module_missing', 'install_failed', 'old_kernel', 'initrd_failed', 'grub_failed', 'xorg_failed', 'clean', 'clean_absent']
for case in cases:
    with tempfile.TemporaryDirectory(prefix='nouveau-test-') as tmp:
        root = Path(tmp)
        etc = root / 'etc'
        for directory in ['modprobe.d', 'X11/xorg.conf.d', 'modules-load.d', 'udev/rules.d']:
            (etc / directory).mkdir(parents=True)
        blacklist = etc / 'modprobe.d/blacklist-nouveau-x11.conf'
        stale = etc / 'modules-load.d/nvidia-uvm.conf'
        stale.write_text('nvidia-uvm\n')
        if case == 'clean':
            blacklist.write_text('blacklist nvidia\n')
        recipe = root / 'recipe.sh'
        recipe.write_text(source.replace('/etc/', str(etc) + '/'))
        for name in ['common.sh', 'common-outformat.sh']:
            (root / name).write_text((recipe_dir / name).read_text())
        mock = root / 'mock'
        mock.write_text('''#!/bin/sh
cmd=${0##*/}
echo "$cmd $*" >> "$TEST_LOG"
case "$cmd:$*" in
  'id:-u') echo 0 ;;
  'uname:-r') echo 7.1.8-7.1-alt1 ;;
  'epm:print info -s') echo alt ;;
  'epm:update-kernel --used-kflavour') echo 7.1 ;;
  'epm:update-kernel --check-run-kernel') [ "$TEST_CASE" != old_kernel ] ;;
  epm:install*) [ "$TEST_CASE" != install_failed ] ;;
  modinfo:*) [ "$TEST_CASE" != module_missing ] ;;
  make-initrd:*) [ "$(pwd)" = / ] && [ "$TEST_CASE" != initrd_failed ] ;;
  update-grub:*) [ "$TEST_CASE" != grub_failed ] ;;
  xsetup-monitor:*) [ "$TEST_CASE" != xorg_failed ] ;;
  *) exit 0 ;;
esac
''')
        mock.chmod(0o755)
        for cmd in ['id', 'uname', 'epm', 'modinfo', 'make-initrd', 'update-grub', 'xsetup-monitor']:
            (root / cmd).symlink_to(mock)
        env = dict(os.environ, PATH=f'{root}:/usr/bin:/bin', TEST_LOG=str(root/'log'), TEST_CASE=case)
        args = ['sh', str(recipe), '--run', '']
        if case.startswith('clean'):
            args += ['--clean']
        p = subprocess.run(args, env=env, text=True, capture_output=True)
        log = (root/'log').read_text()
        ok = case in ['success', 'clean', 'clean_absent']
        assert (p.returncode == 0) == ok, (case, p.stdout, p.stderr)
        if case == 'success':
            assert 'blacklist nvidia\n' in blacklist.read_text()
            assert not stale.exists()
            assert 'make-initrd -k 7.1.8-7.1-alt1' in log
            assert 'i586-' not in log
            assert 'Done.' in p.stdout
        elif case.startswith('clean'):
            assert not blacklist.exists()
            assert 'make-initrd -k ' in log and 'update-grub' in log
            assert 'epm install' not in log
        else:
            assert 'Done.' not in p.stdout
            if case in ['module_missing', 'install_failed', 'old_kernel']:
                assert not blacklist.exists() and stale.exists()
                assert 'xsetup-monitor' not in log
            if case == 'initrd_failed':
                assert 'update-grub' not in log
        print(f'PASS {case}')
