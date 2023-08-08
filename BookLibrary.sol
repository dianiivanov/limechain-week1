// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/access/Ownable.sol";

library StringsPagination {
    function getPage(string[] storage _arr, uint256 _page, uint256 _resultsPerPage) external view returns (string[] memory)
    {
        uint256 startIndex = _page * _resultsPerPage;
        uint256 endIndex = startIndex + _resultsPerPage;
        if (_arr.length == 0 || startIndex > _arr.length - 1) {
            return new string[](0);
        }

        if (endIndex > _arr.length) {
            endIndex = _arr.length;
        }

        string[] memory result = new string[](endIndex - startIndex);

        uint256 _resultArrIdx = 0;
        
        for (;startIndex < endIndex; startIndex++) {
            result[_resultArrIdx] = _arr[startIndex];
            _resultArrIdx++;
        }

        return result;
    }
}

contract BookLibrary is Ownable {
    error BookAlreadyBorrowed(address borrower, string bookName);
    error BookUnavailable(address borrower, string bookName);
    error BookNotBorrowed(address borrower, string bookName);


    struct BookInfo {
        bool isBookRecordedInLibrary;
        uint32 copies;
        address[] allBorrowersEver;
    }

    struct Borrowing {
        bool isBorrowed;
        bool isRecorded;
    }

    using StringsPagination for string[];
    mapping (bytes32 => mapping(address => Borrowing)) private bookToBorrower;
    mapping (bytes32 => BookInfo) private bookToInfo;
    string[] private books;

    function addBooks(string calldata _bookName, uint32 _numberOfCopies) external onlyOwner {
        bytes32 bookNameInBytes32 = stringToBytes32(_bookName);
        if(!bookToInfo[bookNameInBytes32].isBookRecordedInLibrary) {
            books.push(_bookName);
            bookToInfo[bookNameInBytes32].isBookRecordedInLibrary = true;
        }
        bookToInfo[bookNameInBytes32].copies += _numberOfCopies;
    }

    function getBooksPage( uint256 _page, uint256 _resultsPerPage) external view returns(string[] memory) {
       return books.getPage(_page, _resultsPerPage);
    }

    function borrow(string memory _bookName) external {
        bytes32 bookNameInBytes32 = stringToBytes32(_bookName);
        if(bookToBorrower[bookNameInBytes32][msg.sender].isBorrowed) {
            revert BookAlreadyBorrowed(msg.sender, _bookName);
        }
        if(bookToInfo[bookNameInBytes32].copies == 0) {
            revert BookUnavailable(msg.sender, _bookName);
        }

        bookToBorrower[bookNameInBytes32][msg.sender].isBorrowed = true;
        if(!bookToBorrower[bookNameInBytes32][msg.sender].isRecorded) {
            bookToBorrower[bookNameInBytes32][msg.sender].isRecorded = true;
            bookToInfo[bookNameInBytes32].allBorrowersEver.push(msg.sender);
        }
        bookToInfo[bookNameInBytes32].copies--;
    }

    function returnBook(string memory _bookName) external {
        bytes32 bookNameInBytes32 = stringToBytes32(_bookName);
        if(!bookToBorrower[bookNameInBytes32][msg.sender].isBorrowed) {
            revert BookNotBorrowed(msg.sender, _bookName);
        }
        
        bookToBorrower[bookNameInBytes32][msg.sender].isBorrowed = false;
        bookToInfo[bookNameInBytes32].copies++;
    }
    
    function getBooksBorrowers(string memory _bookName) external view returns(address[] memory) {
        return bookToInfo[stringToBytes32(_bookName)].allBorrowersEver;
    }

    function stringToBytes32(string memory str) public pure returns (bytes32) {
        return keccak256(bytes(str));
    }
}
