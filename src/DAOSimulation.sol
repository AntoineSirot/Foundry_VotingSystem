// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract DAOSimulation {
    struct Pool {
        uint id;
        uint startingTimestamp;
        uint finalTimestamp;
        string description;
        string[2] possibilities;
        uint[2] answers;
        address[] participants;
    }

    Pool[] private pools;

    error VotingEnded(uint end, uint current);
    error VotingNotStarted(uint start, uint current);
    error WrongId(uint id);
    error AlreadyVoted(uint id);
    error WrongChoice(uint choice);

    event Voted(uint id, address voter);

    function createPoll(
        uint duration,
        string calldata _description,
        string[2] calldata _possibilities
    ) public returns (uint) {
        uint[2] memory initVotes = [uint256(0), uint256(0)];
        pools.push(
            Pool({
                id: pools.length,
                startingTimestamp: block.timestamp,
                finalTimestamp: (block.timestamp + duration),
                description: _description,
                possibilities: _possibilities,
                answers: initVotes,
                participants: new address[](0)
            })
        );

        return pools.length - 1;
    }

    function voteOnPoll(uint pollId, uint choice) public returns (bool) {
        if (pollId >= pools.length) {
            revert WrongId(pollId);
        }

        if (block.timestamp < pools[pollId].startingTimestamp) {
            revert VotingNotStarted(
                pools[pollId].startingTimestamp,
                block.timestamp
            );
        }

        if (block.timestamp > pools[pollId].finalTimestamp) {
            revert VotingEnded(pools[pollId].finalTimestamp, block.timestamp);
        }

        if (choice != 0 && choice != 1) {
            revert WrongChoice(choice);
        }

        if (hasVoted(pollId, msg.sender)) {
            revert AlreadyVoted(pollId);
        }

        pools[pollId].participants.push(msg.sender);
        pools[pollId].answers[choice] += 1;
        emit Voted(pollId, msg.sender);

        return true;
    }

    function hasVoted(
        uint pollId,
        address participant
    ) internal view returns (bool) {
        address[] memory participants = pools[pollId].participants;

        for (uint i = 0; i < participants.length; i++) {
            if (participants[i] == participant) {
                return true;
            }
        }
        return false;
    }

    function getPoll(
        uint256 _id
    )
        public
        view
        returns (
            uint,
            uint,
            uint,
            string memory,
            string[2] memory,
            uint[2] memory,
            address[] memory
        )
    {
        return (
            pools[_id].id,
            pools[_id].startingTimestamp,
            pools[_id].finalTimestamp,
            pools[_id].description,
            pools[_id].possibilities,
            pools[_id].answers,
            pools[_id].participants
        );
    }

    function getSizeOfPools() public view returns (uint) {
        return pools.length;
    }
}
