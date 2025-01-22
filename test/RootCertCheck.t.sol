// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CertManager} from "../src/CertManager.sol";
import {Asn1Decode, Asn1Ptr, LibAsn1Ptr} from "../src/Asn1Decode.sol";

contract RootCertCheckTest is Test, CertManager {
    using Asn1Decode for bytes;

    // @dev download the root CA cert for AWS nitro enclaves from https://aws-nitro-enclaves.amazonaws.com/AWS_NitroEnclaves_Root-G1.zip
    // @dev convert the base64 encoded pub key into hex to get the cert below
    bytes public constant ROOT_CA_CERT =
        hex"3082021130820196a003020102021100f93175681b90afe11d46ccb4e4e7f856300a06082a8648ce3d0403033049310b3009060355040613025553310f300d060355040a0c06416d617a6f6e310c300a060355040b0c03415753311b301906035504030c126177732e6e6974726f2d656e636c61766573301e170d3139313032383133323830355a170d3439313032383134323830355a3049310b3009060355040613025553310f300d060355040a0c06416d617a6f6e310c300a060355040b0c03415753311b301906035504030c126177732e6e6974726f2d656e636c617665733076301006072a8648ce3d020106052b8104002203620004fc0254eba608c1f36870e29ada90be46383292736e894bfff672d989444b5051e534a4b1f6dbe3c0bc581a32b7b176070ede12d69a3fea211b66e752cf7dd1dd095f6f1370f4170843d9dc100121e4cf63012809664487c9796284304dc53ff4a3423040300f0603551d130101ff040530030101ff301d0603551d0e041604149025b50dd90547e796c396fa729dcf99a9df4b96300e0603551d0f0101ff040403020186300a06082a8648ce3d0403030369003066023100a37f2f91a1c9bd5ee7b8627c1698d255038e1f0343f95b63a9628c3d39809545a11ebcbf2e3b55d8aeee71b4c3d6adf3023100a2f39b1605b27028a5dd4ba069b5016e65b4fbde8fe0061d6a53197f9cdaf5d943bc61fc2beb03cb6fee8d2302f3dff6";

    function setUp() public {
        vm.warp(1732580000);
    }

    function test_ParseCert() public view {
        Asn1Ptr root = ROOT_CA_CERT.root();
        Asn1Ptr tbsCertPtr = ROOT_CA_CERT.firstChildOf(root);
        (uint64 notAfter, int64 maxPathLen, bytes32 subjectHash, bytes memory pubKey) =
            _parseTbs(ROOT_CA_CERT, tbsCertPtr, true);

        bytes32 certHash = keccak256(ROOT_CA_CERT);
        bytes memory cert = abi.encodePacked(true, notAfter, maxPathLen, subjectHash, pubKey);
        assertEq(verified[certHash], cert);
    }
}
