global class DigitalLeaderboardSchedule implements Schedulable {
   global void execute(SchedulableContext ctx) {
        DigitalLeaderboardMainController.SaveTeamPhotos('NA');
        DigitalLeaderboardMainController.SaveTeamPhotos('EMEA');
        DigitalLeaderboardMainController.SaveTeamPhotos('APJ');
        DigitalLeaderboardMainController.SaveTeamPhotos('LA');
        DigitalLeaderboardMainController.SaveTeamPhotos('GLOBAL');
   }   
}