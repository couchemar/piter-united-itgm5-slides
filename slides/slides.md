# Пакетный менеджер Nix в качестве замены virtualenv

---

# Nix — это:

1. Пакетный менеджер:
    * Атомарные операции
    * Update/Rollback
    * Бинарные пакеты или исходники
    * Кросс-платформенность – Linux, MacOS
2. Минималистичный язык:
    * Lambda-функции
    * Динамическая типизация
    * Ленивые вычисления

---

# Derivations и Nix-expressions

# Derivation

Derivation («Вывод», «Деривация») – описание действий необходимых для сборки.

* Деривация – набор аттрибутов;
* для одинаковых атрибутов будет одинаковый результат сборки.

# Что из себя представляет пакет?

Пакет в терминах Nix – это выражение (nix-expression), результатом вычисления
которого будет деривация.

---

# Hello, world!

# Nix-expression (hello.nix)

    !nix
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

---

# Сборка и установка

# Собираем

    $ nix-build '<nixpkgs>' -A hello
    /nix/store/anndcyxqp5i7wih6bccbdmgw87nh6xgm-hello-2.10
    $ ls -l result
    result -> /nix/store/anndcyxqp5i7wih6bccbdmgw87nh6xgm-hello-2.10
    $ ./result/bin/hello
    Hello, world!

# Устанавливаем

    $ nix-env -i hello
    installing ‘hello-2.10’
    $ hello
    Hello, world!

---

# Вернёмся к Python

---

# virtualenv

- Требуется дополнительное описание или скриптование установки не python-зависимостей.
- Сложность контроля за тем что все участники команды используют одни и те же версии зависимостей.
- Необходимость использовать новое окружение под каждый набор зависимостей.
- Все усложняется если появляются зависимости между разрабатываемыми библиотеками.

---

# nix-shell — virtualenv для всего

# Создается на лету

    $ nix-shell -p pythonPackages.python git libxml2 pythonPackages.tornado
    $ python -c 'import tornado; print tornado.version'
    4.1

# Изолированное окружение

    $ nix-shell -p pypy --pure
    $ less
    The program ‘less’ is currently not installed. It is provided by
    several packages. You can install it by typing one of the following:
      nix-env -i busybox
      nix-env -i less

# Устанавливаются зависимости необходимые для сборки

    $ nix-shell '<nixpkgs>' -A pythonPackages.tornado
    $ unpackPhase
    $ cd tornado-4.1/
    $ ./runtests.sh

---

# Приложение web_math

# web_math/run.py

    !python
    from tornado import ioloop, web, version
    import my_math

    class PlusHandler(web.RequestHandler):
        def get(self, a, b):
            self.write({'result': my_math.plus(int(a), int(b))})

    app = web.Application([
        (r'/plus/(\d+)/(\d+)', PlusHandler)
    ])

    if __name__ == '__main__':
        print "Hey I'm Tornado version: ", version
        app.listen(9999)
        ioloop.IOLoop.instance().start()

---

# Упакуем

# web_math/default.nix

    !nix
    {
      pythonPackages ? (import <nixpkgs> {}).pythonPackages,
      tornado ? pythonPackages.tornado_3,
      my-math ? import ../my_math {inherit pythonPackages;}
    }:
    pythonPackages.buildPythonPackage {
      name = "web_math";
      src = ./.;
      buildInputs = [ tornado my-math ];
    }

---

# Очень важная библиотека

# my_math/my_math/__init__.py

    !python
    def plus(a, b):
        return a + b

# my_math/default.nix

    !nix
    { pythonPackages }:
    pythonPackages.buildPythonPackage {
      name = "my-math";
      src = ./.;
    }

---

# Создадим окружение

# По-умолчанию

    $ nix-shell
    $ python run.py
    Hey I'm Tornado version:  3.2.2
    $ curl http://localhost:9999/plus/7/5
    {"result": 12}

# Использую более свежий Tornado

    $ nix-shell --arg tornado 'with import <nixpkgs> {}; pythonPackages.tornado'
    $ python run.py
    Hey I'm Tornado version:  4.1

---

# Улучшенная версия

# my_math/my_math/__init__.py

    !python
    import numpy

    def plus(*args):
        return numpy.sum(args)


# my_math/default.nix

    !nix
    {
      pythonPackages,
      numpy ? pythonPackages.numpy
    }:

    pythonPackages.buildPythonPackage {
      name = "my-math";
      src = ./.;
      propagatedBuildInputs = [ numpy ];
    }

$ nix-shell --arg my-math 'with import <nixpkgs> {}; callPackage ../my_math2 {}'

---

# Другие версии Python

# Python3 (жалко что работать не будет)

    $ nix-shell --arg pythonPackages '(import <nixpkgs> {}).python3Packages'

# Или даже PyPy
    
    $ nix-shell --arg pythonPackages '(import <nixpkgs> {}).pypyPackages'

    $ nix-shell --arg pythonPackages '(import <nixpkgs> {}).pypyPackages' \
                --arg tornado '(import <nixpkgs> {}).pypyPackages.tornado'
    $ pypy run.py
    Hey I'm Tornado version:  4.1
    $ curl http://localhost:9999/plus/17/25
    {"result": 42}
