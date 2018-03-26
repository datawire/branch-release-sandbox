# Branch and Release Prototype

Experimental repository to build and test a new branch and release model for the Ambassador project. The end goal of this project is to produce a new Travis CI template that supports the final "approved" model as well as any supporting scripts and documentation.

# Questions Driving the Work

1. How can we support a branch model that allows documentation or adminstrative changes without kicking off a full rebuild and release when the changes are merged to master?

2. How can we have branch and merge strategy that tests a subset of the system for rapid feature development and can we wire it so we perform per-merge-to-master publications of the changes (e.g. "untable" or "edge" artifacts).

3. Can we have a formal release process that produces "stable" releases that have potentially gone through a longer testing cycle than feature branches.

# Terminology

- **Continuous Integration (CI)**: The process of continually testing incoming changes against the target of those changes.
- **Contributor**: A person that makes a change to the source tree.
- **Enhancement**: Generic term for a Feature Request, Bug Fix, Refactor or any other unspecified source code change.
- **Maintainer**: A person that is also a Contributor but has the authority to merge PR's and make releases.
- **Release Candidate**: A release candidate is a Git branch that has a versioned name and runs a complete suite of tests to ensure the changes embodied in the release are ready for production usage.
- **Reviewer**: A maintainer responsible for reviewing a change.

# Development Lifecycle

There are generally three types of changes a project can make:

1. Documentation changes
2. Functional code changes
3. Infrastructure code changes (build scripts etc.)

There are four common operations in a project.

1. Change
2. Build
3. Test
4. Release

## Documentation Changes

Documentation changes are source tree changes that do not impact the functionality of the code in any way and do not alter the source in a way that a rebuilt **software** artifact would be different from the last previously built version. That is, if a contributor changes the formatting or sentence structure of documentation they are not altering the tested software artifact produced by a previous build.

With an exception for versioned documentation, which we are not committed to producing at this point in time, a documentation change does not need to trigger `Build`, `Test` or `Release` operations.

## Code Changes

Code changes alter the source code in a way that requires new testing. A code change warrants the following:

1. Compilation, if necessary.
2. Run fail-fast tests to ensure the change is not entirely broken.
3. Build a packaged / binary artifact from the successfully tested source.

## Infrastructure Changes

Infrastructure changes alter the build, test and release operations of a project. Generally an infrastructure code change means the existing tests should be run and artifacts built to ensure regressions do not happen. That said... infrastructure changes are by far the most complex and also the least frequent and are outside the exploration of this document.

# Rough Sketch

This describes a very rough sketch based on 30 min whiteboard session.

- The only long lived branch is `master`.

# Side note: The Role of Pull Requests... Software Process Philosophy

In GitHub Pull Requests act as the primary mechanism to enable continuous integration. When a repository uses Pull Requests there are generally two strategies contributors employ:

1. Make changes and when the modifications reach an arbitrary point of readiness they open a PR and begin the process of review. 
2. Open a PR early and then begin work on changes until some point where they signal no more changes are forthcoming and the test infrastructure reports the changes are OK.

Both approaches have benefits and drawbacks and there is no "right way", but there is a preference for the second approach in some cases. The second approach causes early and continuous integration to occur tightening the feedback loop for an enhancement. This is important when you have a number of developers working on a project across a variety of enhancements.

A smaller tangential benefit of the second approach is that the socialization of a change occurs early. This avoids blindsiding Maintainers and leading to contentious issues where a (usually non-trivial) change is rejected because it does not fit the Maintainers project design goals or philosophy.

In the case of internal contributors (e.g. Datawire employees and contractors) the early pull request and change socialization may not be necessary because employees have access to a different level of test infrastructure, internal knowledge, and communication pathways with Maintainers. However, for external contributors the opposite is true. External contributors do not get to sit in our office, listen to our meetings or talk directly in person with our engineers.

There is no way to force either contribution model in GitHub but a project should encourage the latter if it wants to succeed as a true open source project because the mechanism for communication and change becomes consistent and transparent to all parties. Further it encourages early and constant feedback on changes. At the same time a project should accept the late PR approach when it is convenient.

## Documentation Change Workflow 

This is how a contributor should make a documentation update out of band from a feature, for example, because they are fixing errata.

1. Create a branch for work that starts with `nobuild` or preferably `nobuild/`.
2. Modify the source tree.
3. Commit and Push their branch changes to the remote `origin`.
4. Open a PR for the change.
5. Have someone review the change if necessary.
    - Repeat step 2 and 3 as necessary.
6. Merge the PR to master and delete the branch.

After step (4) the system **SHOULD NOT** rebuild the source tree.

## Enhancement Workflow

This is how an internal or external contributor might begin an enhancement to the codebase using the **Early PR** approach:

1. Create a branch for work that starts with `dev` or preferably `dev/`.
2. Push their branch to the remote `origin`.
3. Open a PR for their branch.
4. Begin pushing commits to the branch.
5. Incorporate feedback from reviewers and from CI.

This is how an internal or external contributor might begin an enhancement to the codebase using the **Late PR** approach:

1. Create a branch for work that starts with `dev` or preferably `dev/`.
2. Modify the source tree.
3. Commit and Push their branch changes to the remote `origin`.
4. Open a PR for their branch.
5. Incorporate feedback from reviewers and from CI.

Development branches always run fail-fast tests (e.g. unit) on every commit.

**NOTE**: It is recommended but not required that developers create a PR for changes as soon as possible because it give them an easy way to see Travis run and test their change against the current `master` branch. This will be important as more developers begin contributting to Ambassador. A second benefit of this is that it allows early socializatin of pending changes.

### Merge Enhancement PR

When an enhancement PR is ready to make it onto `master` then a Maintainer should merge the PR. When Travis sees the merge to master it runs and creates an `edge` build artifact which is just an Ambassador Docker image tagged with the matching short Git SHA that triggered the build.

## Release Candidate Workflow

This is how a maintainer should trigger a release candidate:

1. Create a branch for the release that starts with `rc/`. The name of the release candidate branch generally will be `rc/${XYZ}` where `<XYZ>` is some kind of versioning scheme such as semver. 

2. Create a PR for the branch. This will cause GitHub to invoke Travis CI with a Pull Request. 

## Release Workflow

This is how a maintainer should trigger a release:

1. Create an annotated git tag referencing the SHA of the accepted Release Candidate PR.
2. Push the new git tag into GitHub.

GitHub should send a tag notification to Travis CI which in turn performs the below tasks:

1. Create a Docker registry tag (Quay.io) that maps tag :v${XYZ} to :${GIT_SHA}.
2. Update Scout's `app,json` with the latest released version.
3. Send something to Email / Slack / Gitter announcing the release.
