public with sharing class Jive_CaseCommentsComponentController {
		
		public Boolean showComment{get; set;} 

		public Boolean showButton{get; set;} {showButton = true;}
		public String insertComment{get; set;}
		public Id caseId {get; set;}
		public cComments[] comments{
		get{
		List<cComments> comments = new List<cComments>();
		for(CaseComment comment : [Select LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, IsPublished, CreatedDate, CreatedBy.Id, CreatedBy.Name, CommentBody From CaseComment c where ParentId = :caseId order by c.LastModifiedDate desc])
		{
		cComments tempcComment = new cComments();
		tempcComment.cComment = comment;

		// Build String to display.
		tempcComment.commentText = '<b>Created By: <a href=\'/' + comment.CreatedBy.Id + '\'>' + comment.CreatedBy.Name + '</a> (' + comment.CreatedDate.format() + ') | ';
		//tempcComment.commentText += 'Last Modified By: <a href=\'/' + comment.LastModifiedBy.Id + '\'>' + comment.LastModifiedBy.Name + '</a> (' + comment.LastModifiedDate.format() + ')</b><br>';
		tempcComment.commentText += comment.CommentBody;

		if(comment.IsPublished)
		tempcComment.PublicPrivateAction = 'Make Private';
		else
		tempcComment.PublicPrivateAction = 'Make Public';
		//Add to list
		comments.add(tempcComment);	
		}
		return comments;
		}

		set;
		}

		public void insertComment() {
			CaseComment tempComment = new CaseComment();
	        tempComment.CommentBody = insertComment; 
	        tempComment.ParentId = caseId;
	        insert tempComment;
	        insertComment = '';
	        showComment = false;
	        showButton = true;  
    	}

		public void NewComment()
			{
			showButton = false;
			showComment = true;
			}


		public class cComments {

			public CaseComment cComment {get; set;}
			public String commentText {get; set;}
			public String PublicPrivateAction {get; set;}
		}

}