// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    // struct
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;                 // target amount
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
    }

    // mapping
    mapping(uint256 => Campaign) public campaigns;

    // a global variable - track number of campaigns in order to give them ids
    uint256 public numberOfCampaigns = 0;

    /* CAMPAIGN MAPPING FUNCTIONS */
    //--- createCampaign
    function createCampaign(
        address _owner, 
        string memory _title, 
        string memory _description, 
        uint256 _target, 
        uint256 _deadline, 
        string memory _image
    ) public returns (uint256) {
        // ^ return the index /aka id of a specific campaign
        Campaign storage campaign = campaigns[numberOfCampaigns];

        // check/test to see if everything is good
        require(campaign.deadline < block.timestamp, "The deadline should be a date in the future.");

        // if we are satisfied with the timing
        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        // once all is set up, then increment number of campaigns
        numberOfCampaigns++;

        // return the index of the most recently created campaign
        return numberOfCampaigns -1;
    }
    
    //--- donateToCampaign
    function donateToCampaign(uint256 _id) public payable {
        //
        uint256 amount = msg.value;

        // NOTE: campaigns is the mapping created above
        Campaign storage campaign = campaigns[_id];

        // this campaign is the particular campaign selected to donate to
        campaign.donators.push(msg.sender);      // push the address of the person that donated
        campaign.donations.push(amount);

        //transaction sent - y or n
        (bool sent, ) = payable(campaign.owner).call{value: amount}("");
        // NOTE: payable returns two things, here only using one of them

        // if donation sent successfully, then amounted collected increases from previous total to include the new amount
        if (sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }
    
    // fetch the donators to see who donated to specific campaigs/ param: which campaign by id/ to view will return array of addresses and donation values previously stored in memory
    function getDonators(uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (
            campaigns[_id].donators,
            campaigns[_id].donations
        );
    }
    
    // takes no parameters because want to return all campaigns
    function getCampaigns() public view returns (Campaign[] memory) {
        //create a new variable called allCampaigns of type 'array of as many campaign structures as there are campaigns
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);
        // NOTE: 

        // loop through all the campaigns and populate that variable
        for (uint i = 0; i < numberOfCampaigns; i++) {
            // get a Campaign from storage called item, and populate campaigns
            Campaign storage item = campaigns[i];
            // get above campaign from storage and populate straight to allCampaigns
            allCampaigns[i] = item;
        }

        return allCampaigns;        // NOTE: see end of line 86: ...returns (Campaign[] memory)
    }
}