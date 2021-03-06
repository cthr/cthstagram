pragma solidity ^0.8.1;

contract ImageUpload {
    
    struct Image {
        string name;
        address uploader;
        string[] data;
    }
    
    uint256 public uploadID = 0;

    mapping(uint256 => Image) public images;
    mapping(address => uint256[]) public users;
    
    function create(string memory name, uint32 size) public payable {
        // Set cost to upload
        require(msg.value >= 0.01 ether);
        
        // Create the image
        Image memory image;
        image.name = name;
        image.uploader = msg.sender;
        image.data = new string[](size);
        
        // Map the imageID to the image
        images[uploadID] = image;
        
        users[msg.sender].push(uploadID);
        
        // Increment the upload ID
        uploadID += 1;
    }
    
    function uploadChunk(uint256 id, uint32 index, string memory data) public {
        require(msg.sender == images[id].uploader);
        images[id].data[index] = data;
    }
    
    function getImageName(uint256 id) public view returns(string memory) {
        return images[id].name;
    }
    
    function getImageUploader(uint256 id) public view returns(address) {
        return images[id].uploader;
    }
    
    function getImageChunks(uint256 id) public view returns(string[] memory) {
        return images[id].data;
    }
    
    function getImageChunk(uint256 id, uint32 index) public view returns(string memory) {
        return images[id].data[index];
    }
    
    function getImageIDsByAddress(address user) public view returns(uint256[] memory) {
        return users[user];
    }
    
}