// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "./Ownable.sol";

contract BookLibrary is Ownable {
    struct BookInfo {
        bool isRecorded;
        uint32 copies;
        address[] allBorrowersEver;
    }

    struct Borrowing {
        bool isBorrowed;
        bool isRecorded;
    }

    mapping (string => mapping(address => Borrowing)) private bookToBorrower;
    mapping (string => BookInfo) private bookToInfo;
    string[] private books;

    function addBooks(string calldata _bookName, uint32 _numberOfCopies) public onlyOwner {
        if(!bookToInfo[_bookName].isRecorded) {
            books.push(_bookName);
            bookToInfo[_bookName].isRecorded = false;
        }
        bookToInfo[_bookName].copies += _numberOfCopies;
    }

    function getBooks() public view returns(string[] memory) {
       return books;
    }

    function borrow(string memory _bookName) public {
        require(!bookToBorrower[_bookName][msg.sender].isBorrowed, "You have already borrowed this book");
        require(bookToInfo[_bookName].copies > 0, "There are not free copies of that book");

        bookToBorrower[_bookName][msg.sender].isBorrowed = true;
        if(!bookToBorrower[_bookName][msg.sender].isRecorded) {
            bookToBorrower[_bookName][msg.sender].isRecorded = true;
            bookToInfo[_bookName].allBorrowersEver.push(msg.sender);
        }
        bookToInfo[_bookName].copies--;
    }

    function returnBook(string memory _bookName) public {
        require(bookToBorrower[_bookName][msg.sender].isBorrowed, "You didn't borrow this book");
        bookToBorrower[_bookName][msg.sender].isBorrowed = false;
        bookToInfo[_bookName].copies++;
    }
    
    function getBooksBorrowers(string memory _bookName) public view returns(address[] memory) {
        return bookToInfo[_bookName].allBorrowersEver;
    }
}