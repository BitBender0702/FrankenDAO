pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { StakingBase } from "./StakingBase.t.sol";
import { IERC721 } from "../../src/interfaces/IERC721.sol";

contract VotingPowerTest is StakingBase {
    uint FAKE_ID = 12;

    // Test that staking, delegating, and undelegating all adjust voting power.
    function testStakingVP__UndelegatingUpdatesVotingPower() public {
        address staker = frankenpunks.ownerOf(FAKE_ID);
        assert(staking.getVotes(staker) == 0);        

        address owner = mockStakeSingle(FAKE_ID);
        assert(owner == staker);

        uint evilBonus = staking.evilBonus(FAKE_ID);

        assert(staking.getVotes(staker) == 20 + evilBonus);

        vm.prank(staker);
        staking.delegate(address(1));

        assert(staking.getVotes(staker) == 0);

        vm.prank(staker);
        staking.delegate(address(0));

        assert(staking.getVotes(staker) == 20 + evilBonus);
    }

    // Test that unstaking reduces voting power.
    function testStakingVP__UnstakingReducesVotingPower() public {
        address staker = frankenpunks.ownerOf(FAKE_ID);
        assert(staking.getVotes(staker) == 0);        

        address owner = mockStakeSingle(FAKE_ID);
        assert(owner == staker);

        uint evilBonus = staking.evilBonus(FAKE_ID);

        assert(staking.getVotes(staker) == 20 + evilBonus);

        mockUnstakeSingle(FAKE_ID);

        assert(staking.getVotes(staker) == 0);
    }

    // @todo Test that delegating removes community voting power.
    //function testTotalVotingPower() public {
        // addr 1 stake
        // addr 1 creates proposal
        // get addr 1 community voting power
        // get addr 1 token holding voting power
        // assert total voting power == community VP + token VP

        // addr 1 votes on proposal
        // get new total VP
        //assert new votal VP > old total VP
        // assert new total VP = old total VP + (1 * multiple)
    //}
}
