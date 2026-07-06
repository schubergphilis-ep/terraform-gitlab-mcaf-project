# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v1.0.0...v1.1.0) (2026-03-19)


### 🚀 Features

* Add Archive on Destroy ([#23](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/23)) ([46e5326](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/46e53264eb9819f4f142ffa1f330a34f86bc9f5b))
* Add support for mirrored projects ([#22](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/22)) ([53b8add](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/53b8addfa796c1effc09aafeb8a975238db6d9ff))

## [1.0.0](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v0.7.1...v1.0.0) (2025-10-21)


### ⚠ BREAKING CHANGES

* support hidden cicd variables, custom cicd variable descriptions and cron schedules with ranged weekday ([#21](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/21))

### 🚀 Features

* support hidden cicd variables, custom cicd variable descriptions and cron schedules with ranged weekday ([#21](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/21)) ([8420ebb](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/8420ebb0b48b5e16ee10d3c2cf5f81880b665a3b))

## [0.7.1](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v0.7.0...v0.7.1) (2025-09-29)


### 🐛 Fixes

* Add missing outputs ([#20](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/20)) ([be546da](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/be546dada2a6a3359e3859d86b261b29ff5e0939))

## [0.7.0](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v0.6.1...v0.7.0) (2025-03-14)


### 🐛 Fixes

* users and groups in the approval rule ([#18](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/18)) ([5f2587a](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/5f2587aa53b35b1355d440bfd1863792b107a74c))

## [0.6.1](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v0.6.0...v0.6.1) (2025-03-10)


### 🐛 Fixes

* protected branch id ([#16](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/16)) ([4668ce7](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/4668ce7c1c4a6582d16aa7e0dfcd9cffdffd78ac))

## [0.6.0](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v0.5.0...v0.6.0) (2024-12-05)


### 🚀 Features

* add pipeline schedule ([#15](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/15)) ([ee29b41](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/ee29b41b5e585c629409554e40aa08d588c7e82e))

## [0.5.0](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v0.4.1...v0.5.0) (2024-04-24)


### 🚀 Features

* cicd variables input for given project ([#14](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/14)) ([6949aea](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/6949aea53de62c10949d6293288971d4596123ee))
* add project and mr approval rules ([#13](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/13)) ([fd54629](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/fd546299aee46607809655ca758c9f28681e17e7))

## [0.4.1](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v0.4.0...v0.4.1) (2024-04-12)


### 🐛 Fixes

* bug: remove_source_branch_after_merge, default should be true ([#12](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/12)) ([3b49e08](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/3b49e08e7cac28e1e8a4e3617d870432fcaf42f3))

## [0.4.0](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v0.3.0...v0.4.0) (2024-04-12)


### 🚀 Features

* add security best practice CKV_GLB_4 ([#11](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/11)) ([3797da1](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/3797da19c878b3e2fcb7cce00b62b42bd681d6cc))
* add additional settings and change default for prevent_secrets ([#9](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/9)) ([34e2b7d](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/34e2b7db8d65b27fa084d92105214a2bd33ec75f))
* add prevent_secrets variable to project ([#8](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/8)) ([1406c38](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/1406c3824156702a337785dfc8046dfb0ea2bad3))

### 🐛 Fixes

* update actions ([#10](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/10)) ([4277e98](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/4277e98629f59b926904ffb29d75308e5641b7ef))

## [0.3.0](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v0.2.1...v0.3.0) (2024-02-22)


### 🚀 Features

* expand branch protection settings ([#5](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/5)) ([307930e](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/307930ebaf7c984413c95b1a2625c1e95c814743))

## [0.2.1](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v0.2.0...v0.2.1) (2024-01-30)


### 🐛 Fixes

* bug: add outputs ([#4](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/4)) ([54195a5](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/54195a553534e8bc19b23d2de7320531996e9915))

## [0.2.0](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/compare/v0.1.0...v0.2.0) (2024-01-30)


### 🚀 Features

* update module settings ([#3](https://github.com/schubergphilis/terraform-gitlab-mcaf-project/pull/3)) ([1acde9c](https://github.com/schubergphilis-ep/terraform-gitlab-mcaf-project/commit/1acde9caf903f7a6364783b953f61a594ce7a121))

## 0.1.0 (2023-08-16)

