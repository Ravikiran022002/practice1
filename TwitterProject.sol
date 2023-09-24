// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract TwitterProject {
    struct User {
        string username;
        string password;
        bool loggedIn;
    }

    struct Tweet {
        uint id;
        address author;
        string content;
        uint createdAt;
    }

    struct Message {
        uint256 id;
        string content;
        address from;
        address to;
        uint256 createdAt;
    }

    mapping(address => User) private users;
    mapping(uint => Tweet) public tweets;
    mapping(address => uint[]) public tweetsOf;
    mapping(address => Message[]) public conversations;
    mapping(address => mapping(address => bool)) public operators;
    mapping(address => address[]) public following;

    uint private nextId;
    uint private nextMessageId;

    modifier onlyLoggedIn() {
        require(users[msg.sender].loggedIn, "User is not logged in.");
        _;
    }

    function signup(string memory _username, string memory _password) public {
        require(!users[msg.sender].loggedIn, "User is already signed up.");

        users[msg.sender] = User(_username, _password, true);
    }

    function login(string memory _username, string memory _password) public {
        User storage user = users[msg.sender];
        require(!user.loggedIn, "User is already logged in.");
        require(keccak256(bytes(user.username)) == keccak256(bytes(_username)), "Invalid username.");
        require(keccak256(bytes(user.password)) == keccak256(bytes(_password)), "Invalid password.");

        user.loggedIn = true;
    }

    function logout() public onlyLoggedIn {
        users[msg.sender].loggedIn = false;
    }

    function _tweet(address _from, string memory _content) internal onlyLoggedIn {
        require(_from==msg.sender || operators[_from][msg.sender],"You don't have access");
        tweets[nextId] = Tweet(nextId, _from, _content, block.timestamp);
        tweetsOf[_from].push(nextId);
        nextId += 1;
    }

    function _sendMessage(address _from, address _to, string memory _content) internal onlyLoggedIn {
        require(_from==msg.sender || operators[_from][msg.sender],"You don't have access");
        conversations[_from].push(Message(nextMessageId, _content, _from, _to, block.timestamp));
        nextMessageId++;
    }

    function tweet(string memory _content) public onlyLoggedIn {
        _tweet(msg.sender, _content);
    }

    function tweet(address _from, string memory _content) public onlyLoggedIn {
        _tweet(_from, _content);
    }

    function sendMessage(string memory _content, address _to) public onlyLoggedIn {
        _sendMessage(msg.sender, _to, _content);
    }

    function sendMessages(address _from, address _to, string memory _content) public onlyLoggedIn {
        _sendMessage(_from, _to, _content);
    }

    function follow(address _followed) public onlyLoggedIn {
        following[msg.sender].push(_followed);
    }

    function allow(address _operator) public onlyLoggedIn {
        operators[msg.sender][_operator] = true;
    }

    function disallow(address _operator) public onlyLoggedIn {
        operators[msg.sender][_operator] = false;
    }

    function getLatestTweets(uint count) public view onlyLoggedIn returns (Tweet[] memory) {
        require(count > 0 && count <= nextId, "Count is not proper");
        Tweet[] memory _tweets = new Tweet[](count);

        uint j;
        for (uint i = nextId - count; i < nextId; i++) {
            Tweet storage _structure = tweets[i];
            _tweets[j] = Tweet(_structure.id, _structure.author, _structure.content, _structure.createdAt);
            j++;
        }
        return _tweets;
    }

    function getLatestTweetsOfUser(address _user, uint count) public view onlyLoggedIn returns (Tweet[] memory) {
        Tweet[] memory _tweets = new Tweet[](count);
        uint[] memory ids = tweetsOf[_user];
        require(count > 0 && count <= ids.length, "Count is not defined");

        uint j;
        for (uint i = ids.length - count; i < ids.length; i++) {
            Tweet storage _structure = tweets[ids[i]];
            _tweets[j] = Tweet(_structure.id, _structure.author, _structure.content, _structure.createdAt);
            j++;
        }
        return _tweets;
    }
}
