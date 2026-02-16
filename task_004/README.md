# Практические навыки работы с ZFS

## Цель

Научиться самостоятельно устанавливать ZFS, настраивать пулы, изучить основные возможности ZFS

## Описание/Пошаговая инструкция выполнения домашнего задания:

1. Определить алгоритм с наилучшим сжатием:

* определить, какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4)
* создать 4 файловых системы, на каждой применить свой алгоритм сжатия
* для сжатия использовать либо текстовый файл, либо группу файлов

2. Определить настройки пула. С помощью команды zfs import собрать pool ZFS. Командами zfs определить настройки:

* размер хранилища
* тип pool
* значение recordsize
* какое сжатие используется
* какая контрольная сумма используется

3. Работа со снапшотами:

* скопировать файл из удаленной директории
* восстановить файл локально (zfs receive)
* найти зашифрованное сообщение в файле secret_message

# Выполнение

## Подготовка

С помощью VMWare была создана виртуальная машина с Ubuntu 24.04, куда были добавлены 8 дополнительных дисков объемом 1 Гб каждый, а также пакет утилит zfstutils-linux.

## Определение алгоритма с наилучшим сжатием

Создадим 4 zpool'а-зеркала на каждой паре дисков:

```
zpool create pool1 mirror /dev/sdb /dev/sdc
zpool create pool2 mirror /dev/sdd /dev/sde
zpool create pool3 mirror /dev/sdf /dev/sdg
zpool create pool4 mirror /dev/sdh /dev/sdi
```

Проверим, что всё хорошо через `zpool list` и `zpool status`:

```
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
pool1   960M   111K   960M        -         -     2%     0%  1.00x    ONLINE  -
pool2   960M   110K   960M        -         -     2%     0%  1.00x    ONLINE  -
pool3   960M   110K   960M        -         -     2%     0%  1.00x    ONLINE  -
pool4   960M   138K   960M        -         -     3%     0%  1.00x    ONLINE  -
```

```
pool: pool1
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	pool1       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdb     ONLINE       0     0     0
	    sdc     ONLINE       0     0     0

errors: No known data errors

  pool: pool2
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	pool2       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdd     ONLINE       0     0     0
	    sde     ONLINE       0     0     0

errors: No known data errors

  pool: pool3
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	pool3       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdf     ONLINE       0     0     0
	    sdg     ONLINE       0     0     0

errors: No known data errors

  pool: pool4
 state: ONLINE
config:

	NAME        STATE     READ WRITE CKSUM
	pool4       ONLINE       0     0     0
	  mirror-0  ONLINE       0     0     0
	    sdh     ONLINE       0     0     0
	    sdi     ONLINE       0     0     0

errors: No known data errors
```

Добавим для каждого пула свой алгоритм сжатия:

```
zfs set compression=gzip-9 pool1
zfs set compression=zle pool2
zfs set compression=lzjb pool3
zfs set compression=lz4 pool4
```

Проверим через `zfs get compression`:

```
NAME   PROPERTY     VALUE           SOURCE
pool1  compression  gzip-9          local
pool2  compression  zle             local
pool3  compression  lzjb            local
pool4  compression  lz4             local
```

С помощью python-скрипта [`generate.py`](./generate.py) сгенерируем достаточно большой файл, содержащий 500 миллионов символов (итоговый вес составит 477 МБ).

Скопировав файл в каждую из директорий /pool?/, получим такие данные (с учётом сжатия):

```
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
pool1   960M   349M   611M        -         -    14%    36%  1.00x    ONLINE  -
pool2   960M   477M   483M        -         -    13%    49%  1.00x    ONLINE  -
pool3   960M   477M   483M        -         -    10%    49%  1.00x    ONLINE  -
pool4   960M   477M   483M        -         -    12%    49%  1.00x    ONLINE  -
```

Можем видеть, что сжать файл удалось только gzip-9, остальные вообще не справились с этим. Убедимся в этом с помощью `zfs get compressratio`:

```
NAME   PROPERTY       VALUE  SOURCE
pool1  compressratio  1.36x  -
pool2  compressratio  1.00x  -
pool3  compressratio  1.00x  -
pool4  compressratio  1.00x  -
```

Если же воспользоваться [файлом](https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download) из методички, то результаты будут аналогичными тем, что приведены в это самой методичке:

```
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
pool1   960M  11.0M   949M        -         -    14%     1%  1.00x    ONLINE  -
pool2   960M  39.6M   920M        -         -    14%     4%  1.00x    ONLINE  -
pool3   960M  21.8M   938M        -         -    13%     2%  1.00x    ONLINE  -
pool4   960M  17.8M   942M        -         -    14%     1%  1.00x    ONLINE  -
```

```
NAME   PROPERTY       VALUE  SOURCE
pool1  compressratio  3.66x  -
pool2  compressratio  1.00x  -
pool3  compressratio  1.82x  -
pool4  compressratio  2.23x  -
```

Видимо, полностью случайные данные сжимаются плохо большинством алгоритмов.

## Определение настроек пула

Скачаем и разархивируем файл, приведённый выше, затем импортируем его:

```
wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
tar -xzvf archive.tar.gz
zpool import -d zpoolexport/ otus
```

Проверим состояние через `zpool status`:

```
  pool: otus
 state: ONLINE
status: Some supported and requested features are not enabled on the pool.
	The pool can still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
	the pool may no longer be accessible by software that does not support
	the features. See zpool-features(7) for details.
config:

	NAME                                                            STATE     READ WRITE CKSUM
	otus                                                            ONLINE       0     0     0
	  mirror-0                                                      ONLINE       0     0     0
	    /home/hydr0n/linux-professional/task_004/zpoolexport/filea  ONLINE       0     0     0
	    /home/hydr0n/linux-professional/task_004/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors
```

Далее запросим все указанные в задании свойства:

1. Размер хранилища (`zfs get used otus` + `zfs get available otus`):

```
NAME  PROPERTY  VALUE  SOURCE
otus  used      2.04M  -
```
```
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -
```

**Итог: 352.04 МБ**

2. Тип пула (`zfs get readonly otus`):

```
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default
```

**Итог: в пул можно писать**

3. Размер record size (`zfs get recordsize otus`):

```
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
```

**Итог: 128 КБ**

4. Сжатие (`zfs get compression otus`):

```
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local
```

**Итог: zle**

5. Контрольная сумма (`zfs get checksum otus`):

```
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```

**Итог: sha256**

## Работа со снапшотами

Скачаем второй [файл](https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download) и восстановим из него файловую систему:

```
wget -O file2 'https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download'
zfs receive otus/test@today < file2
```

Найдём теперь файл "secret_message (`find /otus/ -name "secret_message"`):

```
/otus/test/task1/file_mess/secret_message
```

И выведем его содержимое (`cat /otus/test/task1/file_mess/secret_message`):

```
https://otus.ru/lessons/linux-hl/
```
