public class ScheduledCBRCertificationsQueuable implements Queueable,Database.AllowsCallouts {
	public void execute(QueueableContext context) {
		SupportOfferingsFlowController ctrlrObj =new SupportOfferingsFlowController();
		ctrlrObj.upsertIntoCBRCertifications();
	}
}