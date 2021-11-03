<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
<!-- [![LinkedIn][linkedin-shield]][linkedin-url] -->



<!-- PROJECT LOGO -->

<!--
<br />

<p align="center">

  <a href="">

    <img src="images/logo.png" alt="Logo" width="80" height="80">

  </a>
-->

<h3 align="center">CipherPact</h3>

  <p align="center">
    Decentralized, trustless and publicly verifiable suite of financial agreements 
    on Ergo and Cardano 
    <br />
<!--
    <a href="https://github.com/CipherSpell/CipherPact"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/CipherSpell/CipherPact">View Demo</a>
    ·
-->
    <a href="https://github.com/CipherSpell/CipherPact/issues">Report Bug</a>
    ·
    <a href="https://github.com/CipherSpell/CipherPact/issues">Request Feature</a>
  </p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

<!--
[![Product Name Screen Shot][product-screenshot]](https://app.cipherpact.com)
-->

With ever-increasing censorship and privacy-violations around the world, there should be tools to circumvent such acts and empower parties to
perform financial agreements while maintaining the anonymity of those involved in the agreement. By substituting what would be 
a mediator or external platform hosting an exchange between two parties with a smart-contract, the mediator will remain fair, transparent 
and have an action-to-action documentation of the event happening without necessarily divulging the identity of the two parties, which 
may then be referred to in the future by any of the parties involved, for posterity or legal purposes.

### Why blockchain-based financial agreements:
* Removal of trust on a third-party acting as mediator, code is law. Because smart contracts and the records they generate are verifiably stored using encryption on a shared ledger, users who don’t know each other can outsource trust to the blockchain rather than relying on a trusted intermediary. 
* The cryptographic design of the blockchain and its use of distributed nodes makes it extremely resistant to hacks or security breaches.  
* The contract is executed when one or more of the parties submits proof of the satisfaction of the terms. 
* Publicly verifiable (actions taken place within an agreement are documented by the smart contract)
* Using code to implement contract terms avoids ambiguity over contract provisions that can lead to disagreements.

### Built With

By launch, smart contracts should be deployed on the Cardano (solidity via [KEVM](https://testnets.cardano.org/en/virtual-machines/kevm/overview/) or Plutus) and Ergo blockchains
* [Solidity](https://soliditylang.org/)
* [Plutus](https://testnets.cardano.org/en/programming-languages/plutus/overview/)
* [ErgoScript](https://docs.ergoplatform.com/ErgoScript.pdf)



[comment]: <> (<!-- GETTING STARTED -->)

[comment]: <> (## Getting Started)

[comment]: <> (This is an example of how you may give instructions on setting up your project locally.)

[comment]: <> (To get a local copy up and running follow these simple example steps.)

[comment]: <> (### Prerequisites)

[comment]: <> (This is an example of how to list things you need to use the software and how to install them.)

[comment]: <> (* npm)

[comment]: <> (  ```sh)

[comment]: <> (  npm install npm@latest -g)

[comment]: <> (  ```)

[comment]: <> (<!-- More relevant for frontend repo -->)

[comment]: <> (### Installation)

[comment]: <> (1. Get a free API Key at [https://example.com]&#40;https://example.com&#41;)

[comment]: <> (2. Clone the repo)

[comment]: <> (   ```sh)

[comment]: <> (   git clone https://github.com/CipherSpell/CipherPact.git)

[comment]: <> (   ```)

[comment]: <> (3. Install NPM packages)

[comment]: <> (   ```sh)

[comment]: <> (   npm install)

[comment]: <> (   ```)

[comment]: <> (4. Enter your API in `config.js`)

[comment]: <> (   ```JS)

[comment]: <> (   const API_KEY = 'ENTER YOUR API';)

[comment]: <> (   ```)



[comment]: <> (<!-- USAGE EXAMPLES -->)

[comment]: <> (## Usage)

[comment]: <> (Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.)

[comment]: <> (_For more examples, please refer to the [Documentation]&#40;https://example.com&#41;_)


<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/CipherSpell/CipherPact/issues) for a list of proposed features (and known issues).

#### Q2 2022
* Cryptographically-verifiable delivery disputes
* Escrow contract -> Solidity to Plutus port
* Initial minimal build of the client-side application
#### Q3-Q4 2022
* Escrow Contract -> Plutus to ErgoScript port
* Zero-Coupon bonds contract implementation in Plutus and ErgoScript
* Legally-binding Payroll contract
* UI design of the client-side application
#### 2023
* UI implementation of the client-side application
* Contract For Differences (CFDs) contract implementation in Plutus and ErgoScript
* Hell or High Water contract implementation in Plutus and ErgoScript

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the GPL-3.0 License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

JKleinne - [@jkleinne](https://twitter.com/jkleinne) - jkleinne@pm.me

Project Link: [https://github.com/CipherSpell/CipherPact](https://github.com/CipherSpell/CipherPact)






<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/CipherSpell/CipherPact?style=for-the-badge
[contributors-url]: https://github.com/CipherSpell/CipherPact/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/CipherSpell/CipherPact?style=for-the-badge
[forks-url]: https://github.com/CipherSpell/CipherPact/network/members
[stars-shield]: https://img.shields.io/github/stars/CipherSpell/CipherPact?style=for-the-badge
[stars-url]: https://github.com/CipherSpell/CipherPact/stargazers
[issues-shield]: https://img.shields.io/github/issues/CipherSpell/CipherPact?style=for-the-badge
[issues-url]: https://github.com/CipherSpell/CipherPact/issues
[license-shield]: https://img.shields.io/github/license/CipherSpell/CipherPact?style=for-the-badge
[license-url]: https://github.com/CipherSpell/CipherPact/blob/master/LICENSE
<!-- [linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/jkleinne -->
[product-screenshot]: images/screenshot.png
