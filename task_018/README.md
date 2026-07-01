# Настраиваем бэкапы

## Цель

Настроить бэкапы.

## Описание/Пошаговая инструкция выполнения домашнего задания:

Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client.


Настроить удаленный бекап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:

* директория для резервных копий: /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB

* репозиторий дле резервных копий должен быть зашифрован ключом или паролем - на ваше усмотрение;

* имя бекапа должно содержать информацию о времени снятия бекапа;

* глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех.
Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов;

* резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации;

* написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на ваше усмотрение;

* настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов.

Запустите стенд на 30 минут.

Убедитесь что резервные копии снимаются.

Остановите бекап, удалите (или переместите) директорию /etc и восстановите ее из бекапа.

# Выполнение

В качестве хоста используется Ubuntu 24.04 с 16 ГБ RAM.

* [Vagrantfile](./Vagrantfile)
* [Ansible-playbook](./ansible/provision.yml)

# Проверка логов

Подключимся по ssh к клиенту, перейдём под root и проверим логи работы сервиса.

При вызове `journalctl -u borg-backup.service --no-pager` на клиентской машине видим логи borg:

```
Jul 07 00:33:11 client systemd[1]: Starting borg-backup.service - Borg Backup...
Jul 07 00:33:14 client borg-backup[12566]: ------------------------------------------------------------------------------
Jul 07 00:33:14 client borg-backup[12566]: Repository: ssh://borg@192.168.56.10/var/backup/repo
Jul 07 00:33:14 client borg-backup[12566]: Archive name: etc-2026-07-07_00:33:12
Jul 07 00:33:14 client borg-backup[12566]: Archive fingerprint: c751cdc459999442ca14c4e2b26ef0b073c4bcfe3c23f519a183b99ff4d6befb
Jul 07 00:33:14 client borg-backup[12566]: Time (start): Tue, 2026-07-07 00:33:14
Jul 07 00:33:14 client borg-backup[12566]: Time (end):   Tue, 2026-07-07 00:33:14
Jul 07 00:33:14 client borg-backup[12566]: Duration: 0.65 seconds
Jul 07 00:33:14 client borg-backup[12566]: Number of files: 429
Jul 07 00:33:14 client borg-backup[12566]: Utilization of max. archive size: 0%
Jul 07 00:33:14 client borg-backup[12566]: ------------------------------------------------------------------------------
Jul 07 00:33:14 client borg-backup[12566]:                        Original size      Compressed size    Deduplicated size
Jul 07 00:33:14 client borg-backup[12566]: This archive:                1.49 MB            649.23 kB            647.56 kB
Jul 07 00:33:14 client borg-backup[12566]: All archives:                1.49 MB            648.58 kB            695.36 kB
Jul 07 00:33:14 client borg-backup[12566]:                        Unique chunks         Total chunks
Jul 07 00:33:14 client borg-backup[12566]: Chunk index:                     413                  422
Jul 07 00:33:14 client borg-backup[12566]: ------------------------------------------------------------------------------
Jul 07 00:33:20 client systemd[1]: borg-backup.service: Deactivated successfully.
Jul 07 00:33:20 client systemd[1]: Finished borg-backup.service - Borg Backup.
Jul 07 00:33:20 client systemd[1]: borg-backup.service: Consumed 4.906s CPU time.
Jul 07 00:38:33 client systemd[1]: Starting borg-backup.service - Borg Backup...
Jul 07 00:38:36 client borg-backup[12579]: ------------------------------------------------------------------------------
Jul 07 00:38:36 client borg-backup[12579]: Repository: ssh://borg@192.168.56.10/var/backup/repo
Jul 07 00:38:36 client borg-backup[12579]: Archive name: etc-2026-07-07_00:38:33
Jul 07 00:38:36 client borg-backup[12579]: Archive fingerprint: 48b2c42f3057fbae0fbe08cdf1850f91c02b07dec44becd586367941274e10ba
Jul 07 00:38:36 client borg-backup[12579]: Time (start): Tue, 2026-07-07 00:38:36
Jul 07 00:38:36 client borg-backup[12579]: Time (end):   Tue, 2026-07-07 00:38:36
Jul 07 00:38:36 client borg-backup[12579]: Duration: 0.15 seconds
Jul 07 00:38:36 client borg-backup[12579]: Number of files: 429
Jul 07 00:38:36 client borg-backup[12579]: Utilization of max. archive size: 0%
Jul 07 00:38:36 client borg-backup[12579]: ------------------------------------------------------------------------------
Jul 07 00:38:36 client borg-backup[12579]:                        Original size      Compressed size    Deduplicated size
Jul 07 00:38:36 client borg-backup[12579]: This archive:                1.49 MB            649.23 kB                645 B
Jul 07 00:38:36 client borg-backup[12579]: All archives:                2.97 MB              1.30 MB            696.01 kB
Jul 07 00:38:36 client borg-backup[12579]:                        Unique chunks         Total chunks
Jul 07 00:38:36 client borg-backup[12579]: Chunk index:                     414                  844
Jul 07 00:38:36 client borg-backup[12579]: ------------------------------------------------------------------------------
Jul 07 00:38:41 client systemd[1]: borg-backup.service: Deactivated successfully.
Jul 07 00:38:41 client systemd[1]: Finished borg-backup.service - Borg Backup.
Jul 07 00:38:41 client systemd[1]: borg-backup.service: Consumed 4.047s CPU time.
Jul 07 00:43:53 client systemd[1]: Starting borg-backup.service - Borg Backup...
Jul 07 00:43:55 client borg-backup[12591]: ------------------------------------------------------------------------------
Jul 07 00:43:55 client borg-backup[12591]: Repository: ssh://borg@192.168.56.10/var/backup/repo
Jul 07 00:43:55 client borg-backup[12591]: Archive name: etc-2026-07-07_00:43:53
Jul 07 00:43:55 client borg-backup[12591]: Archive fingerprint: bad50e003939481cf3d810989bb52293c733cf78cc30709070ea261ab2a7fed1
Jul 07 00:43:55 client borg-backup[12591]: Time (start): Tue, 2026-07-07 00:43:55
Jul 07 00:43:55 client borg-backup[12591]: Time (end):   Tue, 2026-07-07 00:43:55
Jul 07 00:43:55 client borg-backup[12591]: Duration: 0.06 seconds
Jul 07 00:43:55 client borg-backup[12591]: Number of files: 429
Jul 07 00:43:55 client borg-backup[12591]: Utilization of max. archive size: 0%
Jul 07 00:43:55 client borg-backup[12591]: ------------------------------------------------------------------------------
Jul 07 00:43:55 client borg-backup[12591]:                        Original size      Compressed size    Deduplicated size
Jul 07 00:43:55 client borg-backup[12591]: This archive:                1.49 MB            649.23 kB                644 B
Jul 07 00:43:55 client borg-backup[12591]: All archives:                4.46 MB              1.95 MB            696.65 kB
Jul 07 00:43:55 client borg-backup[12591]:                        Unique chunks         Total chunks
Jul 07 00:43:55 client borg-backup[12591]: Chunk index:                     415                 1266
Jul 07 00:43:55 client borg-backup[12591]: ------------------------------------------------------------------------------
Jul 07 00:44:00 client systemd[1]: borg-backup.service: Deactivated successfully.
Jul 07 00:44:00 client systemd[1]: Finished borg-backup.service - Borg Backup.
Jul 07 00:44:00 client systemd[1]: borg-backup.service: Consumed 3.370s CPU time.
Jul 07 00:49:21 client systemd[1]: Starting borg-backup.service - Borg Backup...
Jul 07 00:49:25 client borg-backup[12623]: ------------------------------------------------------------------------------
Jul 07 00:49:25 client borg-backup[12623]: Repository: ssh://borg@192.168.56.10/var/backup/repo
Jul 07 00:49:25 client borg-backup[12623]: Archive name: etc-2026-07-07_00:49:22
Jul 07 00:49:25 client borg-backup[12623]: Archive fingerprint: 74e84075042bb05e3357211b5874302ebd8059f2c68045e467edb6bcc65a0544
Jul 07 00:49:25 client borg-backup[12623]: Time (start): Tue, 2026-07-07 00:49:24
Jul 07 00:49:25 client borg-backup[12623]: Time (end):   Tue, 2026-07-07 00:49:25
Jul 07 00:49:25 client borg-backup[12623]: Duration: 0.10 seconds
Jul 07 00:49:25 client borg-backup[12623]: Number of files: 429
Jul 07 00:49:25 client borg-backup[12623]: Utilization of max. archive size: 0%
Jul 07 00:49:25 client borg-backup[12623]: ------------------------------------------------------------------------------
Jul 07 00:49:25 client borg-backup[12623]:                        Original size      Compressed size    Deduplicated size
Jul 07 00:49:25 client borg-backup[12623]: This archive:                1.49 MB            649.23 kB                647 B
Jul 07 00:49:25 client borg-backup[12623]: All archives:                4.46 MB              1.95 MB            696.65 kB
Jul 07 00:49:25 client borg-backup[12623]:                        Unique chunks         Total chunks
Jul 07 00:49:25 client borg-backup[12623]: Chunk index:                     415                 1266
Jul 07 00:49:25 client borg-backup[12623]: ------------------------------------------------------------------------------
Jul 07 00:49:30 client systemd[1]: borg-backup.service: Deactivated successfully.
Jul 07 00:49:30 client systemd[1]: Finished borg-backup.service - Borg Backup.
Jul 07 00:49:30 client systemd[1]: borg-backup.service: Consumed 4.394s CPU time.
Jul 07 00:54:37 client systemd[1]: Starting borg-backup.service - Borg Backup...
Jul 07 00:54:40 client borg-backup[12630]: ------------------------------------------------------------------------------
Jul 07 00:54:40 client borg-backup[12630]: Repository: ssh://borg@192.168.56.10/var/backup/repo
Jul 07 00:54:40 client borg-backup[12630]: Archive name: etc-2026-07-07_00:54:37
Jul 07 00:54:40 client borg-backup[12630]: Archive fingerprint: a84797074831e26039ccd25e8f399e52a8190376fb39e7c31acb1528fac2dff6
Jul 07 00:54:40 client borg-backup[12630]: Time (start): Tue, 2026-07-07 00:54:39
Jul 07 00:54:40 client borg-backup[12630]: Time (end):   Tue, 2026-07-07 00:54:39
Jul 07 00:54:40 client borg-backup[12630]: Duration: 0.14 seconds
Jul 07 00:54:40 client borg-backup[12630]: Number of files: 429
Jul 07 00:54:40 client borg-backup[12630]: Utilization of max. archive size: 0%
Jul 07 00:54:40 client borg-backup[12630]: ------------------------------------------------------------------------------
Jul 07 00:54:40 client borg-backup[12630]:                        Original size      Compressed size    Deduplicated size
Jul 07 00:54:40 client borg-backup[12630]: This archive:                1.49 MB            649.23 kB                645 B
Jul 07 00:54:40 client borg-backup[12630]: All archives:                4.46 MB              1.95 MB            696.66 kB
Jul 07 00:54:40 client borg-backup[12630]:                        Unique chunks         Total chunks
Jul 07 00:54:40 client borg-backup[12630]: Chunk index:                     415                 1266
Jul 07 00:54:40 client borg-backup[12630]: ------------------------------------------------------------------------------
Jul 07 00:54:45 client systemd[1]: borg-backup.service: Deactivated successfully.
Jul 07 00:54:45 client systemd[1]: Finished borg-backup.service - Borg Backup.
Jul 07 00:54:45 client systemd[1]: borg-backup.service: Consumed 4.357s CPU time.
Jul 07 00:59:53 client systemd[1]: Starting borg-backup.service - Borg Backup...
Jul 07 00:59:56 client borg-backup[12640]: ------------------------------------------------------------------------------
Jul 07 00:59:56 client borg-backup[12640]: Repository: ssh://borg@192.168.56.10/var/backup/repo
Jul 07 00:59:56 client borg-backup[12640]: Archive name: etc-2026-07-07_00:59:54
Jul 07 00:59:56 client borg-backup[12640]: Archive fingerprint: dfa50954bc962e45d7b5d4e622f8747af04cb2304d3ffc4d8db24e4278dd0544
Jul 07 00:59:56 client borg-backup[12640]: Time (start): Tue, 2026-07-07 00:59:56
Jul 07 00:59:56 client borg-backup[12640]: Time (end):   Tue, 2026-07-07 00:59:56
Jul 07 00:59:56 client borg-backup[12640]: Duration: 0.11 seconds
Jul 07 00:59:56 client borg-backup[12640]: Number of files: 429
Jul 07 00:59:56 client borg-backup[12640]: Utilization of max. archive size: 0%
Jul 07 00:59:56 client borg-backup[12640]: ------------------------------------------------------------------------------
Jul 07 00:59:56 client borg-backup[12640]:                        Original size      Compressed size    Deduplicated size
Jul 07 00:59:56 client borg-backup[12640]: This archive:                1.49 MB            649.23 kB                645 B
Jul 07 00:59:56 client borg-backup[12640]: All archives:                4.46 MB              1.95 MB            696.65 kB
Jul 07 00:59:56 client borg-backup[12640]:                        Unique chunks         Total chunks
Jul 07 00:59:56 client borg-backup[12640]: Chunk index:                     415                 1266
Jul 07 00:59:56 client borg-backup[12640]: ------------------------------------------------------------------------------
Jul 07 01:00:01 client systemd[1]: borg-backup.service: Deactivated successfully.
Jul 07 01:00:01 client systemd[1]: Finished borg-backup.service - Borg Backup.
Jul 07 01:00:01 client systemd[1]: borg-backup.service: Consumed 4.056s CPU time.
Jul 07 01:05:09 client systemd[1]: Starting borg-backup.service - Borg Backup...
Jul 07 01:05:12 client borg-backup[12649]: ------------------------------------------------------------------------------
Jul 07 01:05:12 client borg-backup[12649]: Repository: ssh://borg@192.168.56.10/var/backup/repo
Jul 07 01:05:12 client borg-backup[12649]: Archive name: etc-2026-07-07_01:05:09
Jul 07 01:05:12 client borg-backup[12649]: Archive fingerprint: d269b9458d1f2e3878291de517f9644c12cca82c0112be9bd1e9ad98fb364f07
Jul 07 01:05:12 client borg-backup[12649]: Time (start): Tue, 2026-07-07 01:05:12
Jul 07 01:05:12 client borg-backup[12649]: Time (end):   Tue, 2026-07-07 01:05:12
Jul 07 01:05:12 client borg-backup[12649]: Duration: 0.11 seconds
Jul 07 01:05:12 client borg-backup[12649]: Number of files: 429
Jul 07 01:05:12 client borg-backup[12649]: Utilization of max. archive size: 0%
Jul 07 01:05:12 client borg-backup[12649]: ------------------------------------------------------------------------------
Jul 07 01:05:12 client borg-backup[12649]:                        Original size      Compressed size    Deduplicated size
Jul 07 01:05:12 client borg-backup[12649]: This archive:                1.49 MB            649.23 kB                646 B
Jul 07 01:05:12 client borg-backup[12649]: All archives:                4.46 MB              1.95 MB            696.65 kB
Jul 07 01:05:12 client borg-backup[12649]:                        Unique chunks         Total chunks
Jul 07 01:05:12 client borg-backup[12649]: Chunk index:                     415                 1266
Jul 07 01:05:12 client borg-backup[12649]: ------------------------------------------------------------------------------
Jul 07 01:05:17 client systemd[1]: borg-backup.service: Deactivated successfully.
Jul 07 01:05:17 client systemd[1]: Finished borg-backup.service - Borg Backup.
Jul 07 01:05:17 client systemd[1]: borg-backup.service: Consumed 3.809s CPU time.
Jul 07 01:10:27 client systemd[1]: Starting borg-backup.service - Borg Backup...
Jul 07 01:10:30 client borg-backup[12658]: ------------------------------------------------------------------------------
Jul 07 01:10:30 client borg-backup[12658]: Repository: ssh://borg@192.168.56.10/var/backup/repo
Jul 07 01:10:30 client borg-backup[12658]: Archive name: etc-2026-07-07_01:10:27
Jul 07 01:10:30 client borg-backup[12658]: Archive fingerprint: 2c46dbc594beabdcb65c81ac40a34bc97da7fa860c6908ee79f8c0ef8af572fb
Jul 07 01:10:30 client borg-backup[12658]: Time (start): Tue, 2026-07-07 01:10:29
Jul 07 01:10:30 client borg-backup[12658]: Time (end):   Tue, 2026-07-07 01:10:29
Jul 07 01:10:30 client borg-backup[12658]: Duration: 0.08 seconds
Jul 07 01:10:30 client borg-backup[12658]: Number of files: 429
Jul 07 01:10:30 client borg-backup[12658]: Utilization of max. archive size: 0%
Jul 07 01:10:30 client borg-backup[12658]: ------------------------------------------------------------------------------
Jul 07 01:10:30 client borg-backup[12658]:                        Original size      Compressed size    Deduplicated size
Jul 07 01:10:30 client borg-backup[12658]: This archive:                1.49 MB            649.23 kB                645 B
Jul 07 01:10:30 client borg-backup[12658]: All archives:                4.46 MB              1.95 MB            696.65 kB
Jul 07 01:10:30 client borg-backup[12658]:                        Unique chunks         Total chunks
Jul 07 01:10:30 client borg-backup[12658]: Chunk index:                     415                 1266
Jul 07 01:10:30 client borg-backup[12658]: ------------------------------------------------------------------------------
Jul 07 01:10:35 client systemd[1]: borg-backup.service: Deactivated successfully.
Jul 07 01:10:35 client systemd[1]: Finished borg-backup.service - Borg Backup.
Jul 07 01:10:35 client systemd[1]: borg-backup.service: Consumed 4.170s CPU time.
```

Проверим наличие backup'ов на сервере с помощью 

```
etc-2026-07-07_00:33:12              Tue, 2026-07-07 00:33:14 [c751cdc459999442ca14c4e2b26ef0b073c4bcfe3c23f519a183b99ff4d6befb]
etc-2026-07-07_01:15:42              Tue, 2026-07-07 01:15:45 [c87c6430c9527cb9b5348c39fe449b217a4b4b8f73595e82ae727ea853e9374a]
```

Бэкапов всего два (как я понял, потому что один является daily, а второй - monthly), и каждый раз borg как-то их перезаписывает при таком частом вызове как у нас (каждые 5 минут).

Удалим директорию /etc и восстановим её из backup'а:

```
systemctl stop borg-backup.timer
cd /root
borg extract borg@192.168.56.10:/var/backup/repo::etc-2026-07-07_01:15:42 etc
rm -r /etc
cp -r /root/etc /
```

Вывод `ls /etc`:

```
adduser.conf		debconf.conf	hostname	 logrotate.conf  nsswitch.conf	rc6.d		subuid-
alternatives		debian_version	hosts		 logrotate.d	 opt		rcS.d		sudo.conf
apparmor		default		hosts.allow	 machine-id	 os-release	reportbug.conf	sudo_logsrvd.conf
apparmor.d		deluser.conf	hosts.deny	 machine-info	 pam.conf	resolv.conf	sudoers
apt			dhcp		init.d		 magic		 pam.d		rmt		sudoers.d
bash.bashrc		dpkg		initramfs-tools  magic.mime	 passwd		rpc		sv
bash_completion		e2scrub.conf	inputrc		 mailcap	 passwd-	rsyslog.conf	sysctl.conf
bindresvport.blacklist	environment	iproute2	 mailcap.order	 perl		rsyslog.d	sysctl.d
binfmt.d		ethertypes	issue		 manpath.config  pm		runit		systemd
ca-certificates		fstab		issue.net	 mime.types	 ppp		security	terminfo
ca-certificates.conf	fstab.old	kernel		 mke2fs.conf	 profile	selinux		timezone
chrony			fuse.conf	kernel-img.conf  modprobe.d	 profile.d	services	tmpfiles.d
cloud-release		gai.conf	ld.so.cache	 modules	 protocols	shadow		ucf.conf
cron.d			groff		ld.so.conf	 modules-load.d  python3	shadow-		udev
cron.daily		group		ld.so.conf.d	 motd		 python3.11	shells		ufw
cron.hourly		group-		libaudit.conf	 mtab		 rc0.d		skel		update-motd.d
cron.monthly		grub.d		locale.alias	 nanorc		 rc1.d		ssh		vim
cron.weekly		gshadow		locale.gen	 netconfig	 rc2.d		ssl		wgetrc
cron.yearly		gshadow-	localtime	 network	 rc3.d		subgid		xattr.conf
crontab			gss		logcheck	 networks	 rc4.d		subgid-		xdg
dbus-1			host.conf	login.defs	 nftables.conf	 rc5.d		subuid
```

Файлы восстановлены.
