// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FundingPlatform {
    // Define a struct for a campaign
    struct Campaign {
        address creator;
        string cause;
        string futurePlans;
        uint startDate;
        uint endDate;
        uint goalAmount;
        uint currentAmount;
        bool isActive;
    }
      mapping(uint=>mapping(address=>uint)) public funders;
    
    Campaign[] public campaigns; // Array to store all campaigns

    // Event when a campaign is created
    event CampaignCreated(uint indexed campaignId, address indexed creator);

    // Modifier to check only campaign creators can perform certain actions
    modifier onlyCampaignCreator(uint _campaignId) {
        require(msg.sender == campaigns[_campaignId].creator, "Only the campaign creator can perform this action");
        _;
    }

    // Modifier to check whether a campaign is active
    modifier onlyActiveCampaign(uint _campaignId) {
        require(campaigns[_campaignId].isActive, "Campaign is not active");
        _;
    }

    // Function to create a new campaign
    function createCampaign(string memory _cause, string memory _futurePlans, uint _startDate, uint _endDate, uint _goalAmount) public {
        Campaign memory newCampaign = Campaign({
            creator: msg.sender,
            cause: _cause,
            futurePlans: _futurePlans,
            startDate: _startDate,
            endDate: _endDate,
            goalAmount: _goalAmount,
            currentAmount: 0,
            isActive: true
        });

        campaigns.push(newCampaign);
        emit CampaignCreated(campaigns.length - 1, msg.sender);
    }

    // Function for funders to contribute to a campaign
    function fundCampaign(uint _campaignId, uint _fundingAmount) public payable onlyActiveCampaign(_campaignId)
     {
       require(_fundingAmount > 0 && _fundingAmount<=(campaigns[_campaignId].goalAmount-campaigns[_campaignId].currentAmount), "Funding amount must be greater than 0");
       require(funders[_campaignId][msg.sender] == 0, "Funder can only fund once per project");

       funders[_campaignId][msg.sender] = _fundingAmount;
       campaigns[_campaignId].currentAmount += _fundingAmount;
        if(campaigns[_campaignId].currentAmount==campaigns[_campaignId].goalAmount)
        {
          campaigns[_campaignId].isActive=false;
        }
 
     }


    // Function to check the details of a campaign
    function getCampaignDetails(uint _campaignId) public view returns (
        address creator,
        string memory cause,
        string memory futurePlans,
        uint startDate,
        uint endDate,
        uint goalAmount,
        uint currentAmount,
        bool isActive) 
    {
        Campaign memory campaign = campaigns[_campaignId];
        return (campaign.creator,    campaign.cause,   campaign.futurePlans, campaign.startDate,
                campaign.endDate, campaign.goalAmount, campaign.currentAmount, campaign.isActive);
    }

    // Function to get the number of active campaigns
    function getActiveCC() public view returns (uint)
     {
        uint count = 0;
        for (uint i = 0; i < campaigns.length; i++)
         {
            if (campaigns[i].isActive)
             {
                count++;
            }
        }
        return count;
    }
    // Function to get active campaign IDs
    function getActiveCIds() public view returns (uint[] memory)
     {
    uint[] memory activeCId = new uint[](getActiveCC());
    uint count = 0;

    for (uint i = 0; i < campaigns.length; i++) 
    {
        if (campaigns[i].isActive) 
        {
            activeCId[count] = i;
            count++;
        }
    }
    return activeCId;
}

}
