# Работа с mdadm

## Цель

Научиться использовать утилиту для управления программными RAID-массивами в Linux

## Описание/Пошаговая инструкция выполнения домашнего задания:

1. Добавьте в виртуальную машину несколько дисков

2. Соберите RAID-0/1/5/10 на выбор

3. Сломайте и почините RAID

4. Создайте GPT таблицу, пять разделов и смонтируйте их в системе.

# Выполненние

## Добавление дисков в VMWare Settings

Были добавлены 5 дисков объемом 1 Гб каждый.

## Создание RAID-массива

Массив создаётся скриптом [`create_raid.sh`](./create_raid.sh). Используются все 5 дополнительных дисков, уровень RAID - 5.

## Поломка RAID

`sudo mdadm /dev/md0 --fail /dev/sdd`

Результат:

```
mdadm: set /dev/sdd faulty in /dev/md0
```

Проверим, что поломка была успешна (`sudo mdadm -D /dev/md0`):

```
Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       -       0        0        2      removed
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf

       2       8       48        -      faulty   /dev/sdd
```

## Удаление "сломанного" диска

`sudo mdadm /dev/md0 --remove /dev/sdd`

Результат:

`mdadm: hot removed /dev/sdd from /dev/md0`

Проверим, что диск удалён (`sudo mdadm -D /dev/md0`):

```
Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       -       0        0        2      removed
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf
```

Видим, что исчезла строка с `faulty`.

## Добавляем новый диск

`sudo mdadm /dev/md0 --add /dev/sdd`

Результат:

```
mdadm: added /dev/sdd
```

Проверяем, что диск добавлен и массив снова готов к использованию (`sudo mdadm -D /dev/md0`):

```
Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       6       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf
```

## Создание GPT таблицы

`sudo parted -s /dev/md0 mklabel gpt`

## Создание разделов

```
sudo parted /dev/md0 mkpart primary ext4 0% 20%
sudo parted /dev/md0 mkpart primary ext4 20% 40%
sudo parted /dev/md0 mkpart primary ext4 40% 60%
sudo parted /dev/md0 mkpart primary ext4 60% 80%
sudo parted /dev/md0 mkpart primary ext4 80% 100%
```

## Создание ФС на разделах

`for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p${i}; done`

Результат:

```
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 208896 4k blocks and 52304 inodes
Filesystem UUID: 656d3d9c-bbae-485d-98dc-ff44b24effb0
Superblock backups stored on blocks: 
	32768, 98304, 163840

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done
```

Такой вывод повторяется 5 раз (по количеству разделов, очевидно).

## Монтирование разделов в соответствующие каталоги

`sudo mkdir -p /raid/part{1,2,3,4,5}; for i in $(seq 1 5); do sudo mount /dev/md0p${i} /raid/part${i}; done`

Выводим содержимое любой из директорий `/raid/part*` и обнаруживаем там директорию `lost+found`.
