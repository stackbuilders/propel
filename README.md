# Propel [![Build Status](https://secure.travis-ci.org/stackbuilders/propel.png)](http://travis-ci.org/stackbuilders/propel)


Propel is a command that helps you to push to remote repositories while following best practices for
continuous integration.  We believe that before you push to a shared git repository, you should check that
both the local and the Continuous Integration (CI) server are green.  You should also pull with rebase to avoid pointless
merge commits, and Propel uses this behavior as a default.

## Compatibility

Propel currently works with Jenkins, Team City and CI Joe.

## Installing

Propel can be used from the command line.  Install the gem:

    gem install propel

To use propel, simply run 'propel' from the command line.  Without a remote build server configured, it will
just do a pull --rebase && rake && git push.  You can see all available options with propel --help.

You generally want to use propel in conjunction with a CI server.  Just point propel to your CI server by
passing the option --status-url http://ci.example.com/yourbuild.rss.  Propel will figure out if your build is
passing as of the latest commit for Jenkins, Team City and CI Joe.

Once you figure out the options that work for you, just put a .propel file in the root of your project.
Command line parameters override the options found in the configuration file.  Your configuration file should
have one parameter on each line.  For example:

    --status-url http://ci.example.com/job/Test%20project/rssAll
    --wait

This will set the status url for the project, and default to waiting for the CI build to pass if it is currently
failing.

## Credits

Thanks to Jose Carrion (http://joselo.github.com/) for pair programming with me for several hours during the
development of Propel.