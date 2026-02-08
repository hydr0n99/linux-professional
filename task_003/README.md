# Работа с LVM

## Цель

Создавать и управлять логическими томами в LVM

## Описание/Пошаговая инструкция выполнения домашнего задания:

На виртуальной машине с Ubuntu 24.04 и LVM.

1. Уменьшить том под / до 8G
2. Выделить том под /home
3. Выделить том под /var - сделать в mirror
4. /home - сделать том для снапшотов
5. Прописать монтирование в fstab. Попробовать с разными опциями и разными файловыми системами (на выбор)
6. Работа со снапшотами:
  * сгенерить файлы в /home/
  * снять снапшот
  * удалить часть файлов
  * восстановиться со снапшота

# Выполненние

## Добавление дисков в VMWare Settings

Были добавлены 4 диска объёмом 15, 20, 25 и 30 Гб соответственно: `/dev/sdb`, `/dev/sdc`, `/dev/sdd`, `/dev/sde`. Уменьшение тома под / будет до 13 Гб ввиду его изначального размера в 11 Гб.

## Работа с томами и каталогами

Работа с томами и каталогами, соответствующая пунктам задания 1-5, описана в файле [`lvm.sh`](./lvm.sh).

## Работа со снапшотами

Создадим несколько файлов в `/home/`:

`touch /home/file{1..10}`

Создадим снапшот:

`lvcreate -L 500M -s -n home_snap /dev/ubuntu-vg/LV_Home`

Проверим размер с помощью `lvs`:

```
LV        VG        Attr       LSize   Pool Origin  Data%  Meta%  Move Log Cpy%Sync Convert
LV_Home   ubuntu-vg owi-aos---  20,00g                                                     
home_snap ubuntu-vg swi-a-s--- 500,00m      LV_Home 0,47                                   
ubuntu-lv ubuntu-vg -wi-ao----  13,00g                                                     
lv_var    vg_var    rwi-aor---   5,00g                                     100,00 
```

Теперь удалим несколько файлов:

`rm /home/file{1..5}`

Проверим с помощью `ls /home`:

```
file10  file6  file7  file8  file9  hydr0n  lost+found
```

А также проверим размер снапшота с помощью `lvs`:

```
LV        VG        Attr       LSize   Pool Origin  Data%  Meta%  Move Log Cpy%Sync Convert
LV_Home   ubuntu-vg owi-aos---  20,00g                                                     
home_snap ubuntu-vg swi-a-s--- 500,00m      LV_Home 1,74                                   
ubuntu-lv ubuntu-vg -wi-ao----  13,00g                                                     
lv_var    vg_var    rwi-aor---   5,00g                                     100,00 
```

Затем отмонтируем `/home` через `umount /home` (здесь мне пришлось перезагрузиться в recovery mode, т.к. графическая оболочка не позволяла отмонтировать `/home`) и восстановимся со снапшота:

`lvconvert --merge /dev/ubuntu-vg/home_snap`

Проверим наличие файлов через `ls /home`:

```
file1  file10  file2  file3  file4  file5  file6  file7  file8  file9  hydr0n  lost+found
```

И проверим с помощью `lvs`, что снапшот исчез после восстановления:

```
LV        VG        Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
LV_Home   ubuntu-vg -wi-ao---- 20,00g                                                    
ubuntu-lv ubuntu-vg -wi-ao---- 13,00g                                                    
lv_var    vg_var    rwi-aor---  5,00g                                    100,00
```

