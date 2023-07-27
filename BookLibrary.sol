// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/access/Ownable.sol";

contract BookLibrary is Ownable {
    struct BookInfo {
        bool isBookRecordedInLibrary;
        uint32 copies;
        address[] allBorrowersEver;
    }

    struct Borrowing {
        bool isBorrowed;
        bool isRecorded;
    }

    mapping (bytes32 => mapping(address => Borrowing)) private bookToBorrower;
    mapping (bytes32 => BookInfo) private bookToInfo;
    string[] private books;

    function addBooks(string calldata _bookName, uint32 _numberOfCopies) public onlyOwner {
        bytes32 stringInBytes32 = stringToBytes32(_bookName);
        if(!bookToInfo[stringInBytes32].isBookRecordedInLibrary) {
            books.push(_bookName);
            bookToInfo[stringInBytes32].isBookRecordedInLibrary = true;
        }
        bookToInfo[stringInBytes32].copies += _numberOfCopies;
    }

    function getBooks() public view returns(string[] memory) {
       return books;
    }

    function borrow(string memory _bookName) public {
        bytes32 stringInBytes32 = stringToBytes32(_bookName);
        require(!bookToBorrower[stringInBytes32][msg.sender].isBorrowed, "You have already borrowed this book");
        require(bookToInfo[stringInBytes32].copies > 0, "There are not free copies of that book");

        bookToBorrower[stringInBytes32][msg.sender].isBorrowed = true;
        if(!bookToBorrower[stringInBytes32][msg.sender].isRecorded) {
            bookToBorrower[stringInBytes32][msg.sender].isRecorded = true;
            bookToInfo[stringInBytes32].allBorrowersEver.push(msg.sender);
        }
        bookToInfo[stringInBytes32].copies--;
    }

    function returnBook(string memory _bookName) public {
        bytes32 stringInBytes32 = stringToBytes32(_bookName);
        require(bookToBorrower[stringInBytes32][msg.sender].isBorrowed, "You didn't borrow this book");
        bookToBorrower[stringInBytes32][msg.sender].isBorrowed = false;
        bookToInfo[stringInBytes32].copies++;
    }
    
    function getBooksBorrowers(string memory _bookName) public view returns(address[] memory) {
        return bookToInfo[stringToBytes32(_bookName)].allBorrowersEver;
    }

    function stringToBytes32(string memory str) public pure returns (bytes32) {
        return keccak256(bytes(str));
    }
}
