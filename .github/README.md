Prototype program to copy configuration files to multiple hosts, with minimal changes.

Base configuration files are stored in `base/`.
Changes to base config are made by scripts in `pre_install/`, run locally.
Scripts to be executed on target host are in `post_install/`.
Additionally, arbitrary changes can be made to single hosts using `edit_patch.sh` (these changes are saved in `patches/`).

How to use (doesn't actually deploy anything)
```bash
./deploy.sh example host1
```
Host "host3" will have `port=1338` in `/etc/foo.conf`,
any other host will have `port=1337`.


# License
The BSD Zero Clause License (0BSD)

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
