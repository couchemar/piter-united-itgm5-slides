:title: Пакетный менеджер Nix в качестве замены virtualenv
:css: itgm.css

.. title:: Пакетный менеджер Nix в качестве замены virtualenv

----

:id: title-slide

Пакетный менеджер Nix в качестве замены virtualenv
==================================================

Andrey Pavlov / @couchemar
--------------------------

*ITGM#5*

----

Зачем нужно virtualenv?
=======================

virtualenv — позволяет держать зависимости, необходимые различным проектам,
отдельно друг от друга, плюс обеспечивает изолированность от глобально
установленных пакетов.

----

Однако
======

Со своими задачами virtualenv справляется недостаточно хорошо.

----

Почему?
=======

- Если нужны не только python-зависимости, придется использовать глобально
  установленные;
- не python-зависимости нельзя указать в requirements.txt, требуется
  дополнительное описание их установки;
- любое действие с окружением это его изменение;

----

Я хочу проверить свое приложение с другими версиями зависимостей?
=================================================================

- Создать новое окружение?
- Установить в текущее?

----

Nix
===

----

Nix — это:
==========

1. Пакетный менеджер:
    * Атомарные операции
    * Update/Rollback
    * Бинарные пакеты или исходники
    * Кросс-платформенность – Linux, MacOS
2. Минималистичный язык:
    * Lambda-функции
    * Динамическая типизация
    * Ленивые вычисления

----

Derivations и Nix-expressions
=============================

Derivation
----------

Derivation («Вывод», «Деривация») – описание действий необходимых для сборки.

* Деривация – набор аттрибутов;
* для одинаковых атрибутов будет одинаковый результат сборки.

Что из себя представляет пакет?
-------------------------------

Пакет в терминах Nix – это выражение (nix-expression), результатом вычисления
которого будет деривация.

----

Hello, world!
=============

Nix-expression (hello.nix)
--------------------------

.. code:: nix

    { stdenv, fetchurl }:

    stdenv.mkDerivation rec {
      name = "hello-2.10";

      src = fetchurl {
        url = "mirror://gnu/hello/${name}.tar.gz";
        sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
      };

      doCheck = true;

      meta = {
        description = "A program that produces a familiar, friendly greeting";
        longDescription = ''
        GNU Hello is a program that prints "Hello, world!" when you run it.
        It is fully customizable.
        '';
        homepage = http://www.gnu.org/software/hello/manual/;
        license = stdenv.lib.licenses.gpl3Plus;
        maintainers = [ stdenv.lib.maintainers.eelco ];
        platforms = stdenv.lib.platforms.all;
      };
    }

----

Сборка и установка
==================

Собираем
--------

::

    $ nix-build '<nixpkgs>' -A hello
    /nix/store/anndcyxqp5i7wih6bccbdmgw87nh6xgm-hello-2.10
    $ ls -l result
    result -> /nix/store/anndcyxqp5i7wih6bccbdmgw87nh6xgm-hello-2.10
    $ ./result/bin/hello
    Hello, world!

Устанавливаем
-------------

::

    $ nix-env -i hello
    installing ‘hello-2.10’
    $ hello
    Hello, world!

----

nix-shell — virtualenv для всего
================================

Создается на лету
-----------------

::

    $ nix-shell -p pythonPackages.python git libxml2 pythonPackages.tornado
    $ python -c 'import tornado; print tornado.version'
    4.1

Изолированное окружение
-----------------------

::

    $ nix-shell -p pypy --pure
    $ less
    The program ‘less’ is currently not installed. It is provided by
    several packages. You can install it by typing one of the following:
      nix-env -i busybox
      nix-env -i less

Окружение для сборки
--------------------

::

    $ nix-shell '<nixpkgs>' -A pythonPackages.tornado
    $ unpackPhase
    $ cd tornado-4.1/
    $ ./runtests.sh

----

Приложение web_math
===================

web_math/run.py
---------------

.. code:: python

    @web_math_run_py@

----

Упакуем
=======

web_math/default.nix
--------------------

.. code:: nix

    @web_math_default_nix@

----

Очень важная библиотека
=======================

my_math/my_math/__init__.py
---------------------------

.. code:: python

    @my_math_init_py@

my_math/default.nix
-------------------

.. code:: nix

    @my_math_default_nix@

----

Создадим окружение
==================

По-умолчанию
------------

::

    $ nix-shell
    $ python run.py
    Hey I'm Tornado version:  3.2.2
    $ curl "http://localhost:9999/plus?a=1&b=2&c=3"
    {"result": 6}

Используем более свежий Tornado
-------------------------------

::

    $ nix-shell --arg tornado 'with import <nixpkgs> {}; pythonPackages.tornado'
    $ python run.py
    Hey I'm Tornado version:  4.1

----

Улучшенная версия библиотеки
============================

my_math2/my_math/__init_.py
---------------------------

.. code:: python

    @my_math2_init_py@

my_math2/default.nix
--------------------

.. code:: nix

    @my_math2_default_nix@

::

    $ nix-shell --arg my-math 'with import <nixpkgs> {}; callPackage ../my_math2 {}'
    $ curl "http://localhost:9999/plus?a=1&b=2&c=3"
    {"result": 6}

----

Другие версии Python
====================

Python3 (жалко, что работать не будет)
--------------------------------------

::

    $ nix-shell --arg pythonPackages '(import <nixpkgs> {}).python3Packages'

Или даже PyPy
-------------

::

    $ nix-shell --arg pythonPackages '(import <nixpkgs> {}).pypyPackages'

    $ nix-shell --arg pythonPackages '(import <nixpkgs> {}).pypyPackages' \
                --arg tornado '(import <nixpkgs> {}).pypyPackages.tornado'
    $ pypy run.py
    Hey I'm Tornado version:  4.1
    $ curl "http://localhost:9999/plus?a=10&b=12&c=13&d=7"
    {"result": 42}

----

Nix – единый менеджер пакетов
=============================

* Perl
* Python
* Go
* Node.js
* OCaml
* Rust
* Haskell
* Ruby
* Java
* И другие

И даже эта презентация подготовлена с помощью Nix:
`github.com/couchemar/piter-united-itgm5-slides`_.

.. _github.com/couchemar/piter-united-itgm5-slides: https://github.com/couchemar/piter-united-itgm5-slides

----

:id: end-slide

Спасибо
=======
