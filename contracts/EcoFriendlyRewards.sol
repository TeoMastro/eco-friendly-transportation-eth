// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EcoFriendlyRewards {
    // entity declaration for the contract
    struct Vehicle {
        uint userId;
        string make;
        string model;
        EmissionLevel emissionLevel;
    }

    struct User {
        uint id;
        string name;
    }

    struct Business {
        string name;
        uint id;
    }

    struct LeaderboardEntry {
        uint userId;
        uint points;
    }

    enum EmissionLevel {
        Electric,
        Hybrid,
        LowEmission
    }

    mapping(uint => Vehicle) public vehicles;
    mapping(uint => uint) public ownerRewards;
    mapping(uint => Business) public businesses;
    mapping(uint => bool) public registeredBusinesses;
    mapping(uint => User) public users;
    mapping(uint => bool) public registeredUsers;
    mapping(address => bool) public isAdmin;

    // variables used in the contract to count vehicles, businesses and users.
    // the deployer address is kept so we know who is the system admin and a flag is used to know if the system is under maintenance or not.
    uint public vehicleCount;
    uint public businessCount;
    uint public usersCount;
    address public deployer;
    bool public isPaused = false;
    LeaderboardEntry[] public leaderboard;

    // the event emitted when the user earns points
    event RewardPointsEarned(
        uint userId,
        string make,
        string model,
        uint points
    );

    // modifiers to check if user is admin and if system is active with error handling.
    modifier onlyAdmin() {
        require(msg.sender == deployer, "Not authorized");
        _;
    }

    modifier systemActive() {
        require(!isPaused, "The system is currently paused");
        _;
    }

    // rus on script init (see interactWithContract.js)
    constructor() {
        deployer = msg.sender;
        isAdmin[deployer] = true;
    }

    // functions used to register users, businesses and vehicles
    function registerBusiness(
        string memory _name,
        uint _id
    ) public onlyAdmin systemActive {
        businesses[_id] = Business(_name, _id);
        registeredBusinesses[_id] = true;
        businessCount++;
    }

    function registerUser(
        string memory _name,
        uint _id
    ) public onlyAdmin systemActive {
        users[_id] = User(_id, _name);
        registeredUsers[_id] = true;
        usersCount++;
        leaderboard.push(LeaderboardEntry(_id, 0));
    }

    function registerVehicle(
        uint _userId,
        string memory _make,
        string memory _model,
        EmissionLevel _emissionLevel
    ) public systemActive {
        vehicles[vehicleCount] = Vehicle(
            _userId,
            _make,
            _model,
            _emissionLevel
        );
        vehicleCount++;
    }

    // report mileage system and reward points calculation based on emmision level
    function reportMileage(uint _userId, uint _km) public systemActive {
        Vehicle memory vehicle = vehicles[_userId];
        uint rewardPoints;
        if (vehicle.emissionLevel == EmissionLevel.Electric) {
            rewardPoints = 8 * _km;
        } else if (vehicle.emissionLevel == EmissionLevel.Hybrid) {
            rewardPoints = 4 * _km;
        } else if (vehicle.emissionLevel == EmissionLevel.LowEmission) {
            rewardPoints = 1 * _km;
        }
        ownerRewards[vehicle.userId] += rewardPoints;
        emit RewardPointsEarned(
            vehicle.userId,
            vehicle.make,
            vehicle.model,
            rewardPoints
        );
    }

    // redeem points functions with all its requirements (as asked)
    function redeemPoints(
        uint _userId,
        uint _businessID,
        uint _points
    ) public systemActive {
        require(
            ownerRewards[_userId] >= 1000,
            "Minimum 1000 points required to redeem"
        );
        require(ownerRewards[_userId] >= _points, "Not enough reward points");
        require(registeredBusinesses[_businessID], "Business not registered");
        ownerRewards[_userId] -= _points;
        updateLeaderboard(_userId, ownerRewards[_userId]);
    }

    // update and sort the leaderboard
    function updateLeaderboard(uint _userId, uint _newPoints) internal {
        bool found = false;
        for (uint i = 0; i < leaderboard.length; i++) {
            if (leaderboard[i].userId == _userId) {
                leaderboard[i].points = _newPoints;
                found = true;
                break;
            }
        }
        if (!found) {
            leaderboard.push(LeaderboardEntry(_userId, _newPoints));
        }
        sortLeaderboard();
    }

    function sortLeaderboard() internal {
        for (uint i = 0; i < leaderboard.length; i++) {
            for (uint j = i + 1; j < leaderboard.length; j++) {
                if (leaderboard[j].points > leaderboard[i].points) {
                    LeaderboardEntry memory temp = leaderboard[i];
                    leaderboard[i] = leaderboard[j];
                    leaderboard[j] = temp;
                }
            }
        }
    }

    // get the top 10 users from the leaderboard
    function getTop10Users() public view returns (LeaderboardEntry[] memory) {
        uint length = leaderboard.length < 10 ? leaderboard.length : 10;
        LeaderboardEntry[] memory topUsers = new LeaderboardEntry[](length);
        for (uint i = 0; i < length; i++) {
            topUsers[i] = leaderboard[i];
        }
        return topUsers;
    }

    // functions used to pause and unpause the system for maintenance
    function pauseSystem() public onlyAdmin {
        isPaused = true;
    }

    function unpauseSystem() public onlyAdmin {
        isPaused = false;
    }

    // used to destroy the contract if needed
    function destroyContract() public onlyAdmin {
        selfdestruct(payable(deployer));
    }
}
