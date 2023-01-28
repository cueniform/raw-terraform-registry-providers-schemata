# TODO

- Stop using GHA runner's built-in `terraform`.

- Use for provider polling age-related queue:

```
git ls-tree -rtz --name-only HEAD . | xargs -0 -I{} sh -xc 'touch --date "$(git log -1 --pretty="format:%aD" {})" {}' 2>&1 | fgrep -v '+ git log'
```
