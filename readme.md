# schedulostfalia by <a href="https://github.com/igeligel">igeligel</a>

<div align="center"><a href="https://www.paypal.me/kevinpeters96/1"><img src="https://img.shields.io/badge/Donate-Paypal-003087.svg?style=flat" alt="badge Donate" /></a> <a href="https://steamcommunity.com/tradeoffer/new/?partner=68364320&token=CzTCv8JM"><img src="https://img.shields.io/badge/Donate-Steam-000000.svg?style=flat" alt="badge Donate" /></a> <a href="https://github.com/igeligel/BackpackLogin/blob/master/LICENSE.md"><img src="https://img.shields.io/badge/License-MIT-1da1f2.svg?style=flat" alt="badge License" /></a> </div>

<div align="center"><img src ="http://i.imgur.com/wSorNZN.gif"/></div>

## Description

> Parser for the [time schedule of the Ostfalia Hochschule für angewandte Wissenschaften](http://splus.ostfalia.de/semesterplan123.php) in Wolfenbüttel. It will give you an easily readable format on your console via [Haskell](https://www.haskell.org/)/[GHCI](https://downloads.haskell.org/~ghc/latest/docs/html/users_guide/ghci.html).

## Dependencies

This library is using wreq to do HTTP Requests so you need to install it before using the library. To install this refer to [Installation](#installation), You also need cabal for the installation.

| Dependency | Version |
| -- | -- |
| wreq | -/- |


## Installation

To install the dependencies you need to install [Cabal](https://www.haskell.org/cabal/).


You have to install [wreq](https://hackage.haskell.org/package/wreq) in order to run this project. To do so type following into your console:

```bash
cabal update
cabal install -j --disable-tests wreq
```

After this you can clone this repository by using:

```bash
git clone https://github.com/igeligel/schedulostfalia.git
```

## How To Use

Switch to the src directory by:

```bash
cd ./src
```

After this run the [GHCI](https://www.haskell.org/ghc/):

```bash
ghci
```

Then you should load the the core of this project by typing:

```bash
Prelude> :l core.hs
```

After this you can run the main function of this repository which is called ``getSchedule``. This function will take two parameters:

| Name | Type | Description |
| -- | -- | -- |
| CourseId | String | Id of the course. For a full list of courses lookup [this csv](https://github.com/igeligel/schedulostfalia/blob/master/docs/course-list.csv). |
| Week | Integer | Number of the week you want to lookup. |

## Examples

Example Call:

```bash
Prelude> getSchedule "SPLUS7A3292" 16
```

Output:

```bash
[((8,15),(9,45),"Thursday","Grundlagen des Programmierens - VL","H&ouml;rsaal 252","Prof. Dr. F. H&ouml;ppner"),((10,0),(11,30),"Thursday","Grundlagen des Programmierens - VL","H&ouml;rsaal 252","Prof. Dr. F. H&ouml;ppner"),((12,0),(13,30),"Thursday","Diskrete Strukturen","H&ouml;rsaal 252","Prof. Dr. P. Riegler"),((12,0),(13,30),"Friday","Technische Grundlagen der Informatik - VL","11/1","Dipl.-Ing. K. Dammann"),((14,15),(15,45),"Thursday","Technische Grundlagen der Informatik - VL","11/1","Dipl.-Ing. K. Dammann"),((14,15),(15,45),"Friday","Diskrete Strukturen","H&ouml;rsaal 252","Prof. Dr. P. Riegler")]
```


## Contributing

To contribute please lookup the following styleguides:

- Commits: [here](https://github.com/igeligel/contributing-template/blob/master/commits.md)

## Resources

### Motivation

This project was created in the course 'Weitere Programmiersprache' in the [Ostfalia Hochschule für angewandte Wissenschaften](https://www.ostfalia.de/cms/de/). It is a simple project to show Haskell's ability to parse HTML into structured data.

### Architecture

The architecture contains different modules. Only ``core.hs`` should be touched by the outside.

## Contact

<p align="center">
  <a href="https://discord.gg/HS57euF"><img src="https://img.shields.io/badge/Contact-Discord-7289da.svg" alt="Discord server of Kevin Peters"></a>
  <a href="https://twitter.com/kevinpeters_"><img src="https://img.shields.io/badge/Contact-Twitter-1da1f2.svg" alt="Twitter of Kevin Peters"></a>
  <a href="http://steamcommunity.com/profiles/76561198028630048"><img src="https://img.shields.io/badge/Contact-Steam-000000.svg" alt="Steam Profile of Kevin Peters"></a>
</p>


## License

*schedulostfalia* is realeased under the MIT License.

<h2>Contributors</h2>

<table><thead><tr><th align="center"><a href="https://github.com/igeligel"><img src="https://avatars2.githubusercontent.com/u/12736734?v=3" width="100px;" style="max-width:100%;"><br><sub>igeligel</sub></a><br><p>Contributions: 20</p></th></tbody></table>

## This readme is powered by vue-readme

Check out vue-readme [[Website](https://igeligel.github.io/vue-readme) | [GitHub](https://github.com/igeligel/vue-readme)]
