// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0;

contract EventContract {

    struct Event{
        address organizer;
        string nameOfEvent;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;
    uint public nextId;

    function createEvent(string memory name, uint date, uint price, uint ticketCount) external{
        require(date > block.timestamp, "You can organize event for future date only");
        require(ticketCount > 0, "Organize event with atleast 1 ticket");

        events[nextId] = Event(msg.sender, name , date, price, ticketCount,ticketCount);
        nextId++;
    }

    function buyTicket(uint id, uint quantity) external payable{ 
        require(events[id].date != 0, "This event does not exists");
        require(events[id].date > block.timestamp, "Event has already started/finished");
        
        Event storage _event = events[id];

        require(msg.value == _event.price * quantity, "Ether not enough");
        require(_event.ticketRemain > quantity, "Not enough ticket left");

        _event.ticketRemain -= quantity;
        tickets[msg.sender][id]+= quantity;
    }

    function transferTickets(uint id, uint quantity, address transferTo) external {
        require(events[id].date != 0, "This event does not exists");
        require(events[id].date > block.timestamp, "Event has already started/finished");

        require(tickets[msg.sender][id] >= quantity, "You don't have enough tickets to transfer");
        tickets[msg.sender][id] -= quantity;
        tickets[transferTo][id] += quantity;
    }
}