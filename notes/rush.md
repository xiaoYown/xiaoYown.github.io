- [eslint](https://bereghici.dev/blog/build-a-scalable-front-end-with-rush-monorepo-and-react--eslint+lint-staged)

### Project root commands

```sh
# install
npm install -g @microsoft/rush
# init project
rush init
# Install NPM packages as needed
rush update
# install libraries
rush install
# Do a clean rebuild of everything
rush rebuild

# 所有子项目都添加本地 @orgnization/utils 引用
rush add -p @orgnization/utils -all

# Upgrading to newer versions of your NPM packages
rush update --full

# Only install the NPM packages needed to build "my-project" and the other
# Rush projects that it depends on:
$ rush install --to my-project

# Like with "rush build", you can use "." to refer to the project from your
# shell's current working directory:
$ cd my-project
$ rush install --to .

# Here's how to install dependencies required to do "rush build --from my-project"
$ rush install --from my-project

# Remove all the symlinks created by Rush:
$ rush unlink

# Remove all the temporary files created by Rush, including deleting all
# the NPM packages that were installed in your common folder:
$ rush purge
```

### Packages commands

```sh
# 子项目添加本地库(-p -> --package)
rush add -p @orgnization/utils
```
