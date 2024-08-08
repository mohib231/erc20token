// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "lib/forge-std/src/Test.sol";
import "../src/OurToken.sol";
import "../script/DeployOurToken.s.sol";
// import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract TestOurToken is Test {
    OurToken ourToken;
    DeployOurToken deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 constant STARTING_BALANCE = 100;

    function setUp() external {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function test_bobBalance() public view {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function test_allowanceWorks() public {
        uint256 initialAllowance = 50;
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 25;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(
            ourToken.balanceOf(bob),
            ourToken.balanceOf(alice) + initialAllowance
        );
    }

    function testTransferFrom() public {
        uint256 amount = 100;
        uint256 allowance = 50;

        vm.prank(bob);
        ourToken.approve(alice, allowance);

        // Transfer within allowance
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, allowance);
        assertEq(ourToken.balanceOf(alice), allowance);
        assertEq(
            ourToken.balanceOf(msg.sender) + allowance,
            deployer.INITIAL_SUPPLY() - allowance
        );
        assertEq(ourToken.allowance(msg.sender, bob), 0);

        // Transfer exceeding allowance should revert
        // vm.prank(bob);
        // vm.expectRevert(ERC20InsufficientAllowance);
        // ourToken.transferFrom(address(this), alice, amount);
    }

    function testTransfer() public {
        uint256 amount = 100;
        uint256 initialBalance = ourToken.balanceOf(msg.sender);
        console.log(initialBalance);
        vm.prank(msg.sender);
        ourToken.transfer(bob, amount);
        assertEq(ourToken.balanceOf(bob) - amount, amount);
        assertEq(ourToken.balanceOf(msg.sender), initialBalance - amount);
    }
    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testInitialSupplyIsMintedToDeployer() public {
        // Ensure the total supply matches the initial supply
        uint256 initialSupply = ourToken.balanceOf(msg.sender);

        assertEq(ourToken.totalSupply(), initialSupply+STARTING_BALANCE);

        // Ensure that the deployer received all of the initial supply
        assertEq(ourToken.balanceOf(msg.sender), initialSupply);
    }

    function testTokenNameAndSymbol() public {
        // Check the name of the token
        assertEq(ourToken.name(), "OurToken");

        // Check the symbol of the token
        assertEq(ourToken.symbol(), "OT");
    }
    // function test_balanceAfterTransfer() public {

    // }
}
