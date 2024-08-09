pragma solidity 0.5.16;

contract Gaming {
    /* Our Online gaming contract */
    address owner;
    bool online;


    struct Player {
        uint wins;
        uint losses;
    }

    mapping (address => Player) public players;
    
    
    constructor() public payable {
        owner = msg.sender;
        online = true;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    event GameFunded(address funder, uint amount);
    
    event PlayerWon(address player, uint mysteryNumber);
    event PlayerLost(address player, uint mysteryNumber);
    event PlayerOutput(address player, uint mysteryNumber, uint display);
    event PlayerOutput1(address player, uint mysteryNumber, uint display, string messg);

    function mysteryNumber() private view returns (uint) {
        uint randomNumber = uint(blockhash(block.number-1))%10 + 1;
        return randomNumber;
    }

	function determineWinner(uint number, uint display, bool guess) public pure returns (bool) {
    	if (guess) { // Player guesses the number is lower, returns TRUE
        	return number < display;
    	} else { // Player guesses the number is higher, return FALSE
        	return number > display;
    	}
	}

    function winOrLose(uint display, bool guess) external payable returns (bool, uint) {
        /* Use true for a higher guess, false for a lower guess */
        require(online == true, "The game is not online");
        require(msg.sender.balance > msg.value, "Insufficient funds");
        uint mysteryNumber_ = mysteryNumber();
        bool isWinner = determineWinner(mysteryNumber_, display, guess);
        emit PlayerOutput1(msg.sender, mysteryNumber_, display, "adsad");
        if (isWinner == true) {
            /* Player won */
            emit PlayerOutput(msg.sender, mysteryNumber_, display);
            players[msg.sender].wins += 1;
            msg.sender.transfer(msg.value * 2);
            
            emit PlayerWon(msg.sender, mysteryNumber_); 
            return (true, mysteryNumber_);
        } else if (isWinner == false) {
            /* Player lost */
            emit PlayerOutput(msg.sender, mysteryNumber_, display);
            players[msg.sender].losses += 1;
            
            emit PlayerLost(msg.sender, mysteryNumber_);
            return (false, mysteryNumber_);
        }
    }

    function withdrawFunds() public isOwner {
        msg.sender.transfer(address(this).balance);
    }

    function fundGame() public isOwner payable {
        emit GameFunded(msg.sender, msg.value);
    }

    function() external payable {
    }

}
