package pages.test3;

class Server extends BaseServer
{	
	public function preRender()
	{		
		haxe.Timer.measure(function()
		{
			for (i in 0...100)
			{
				template().questionBlock.create
				({
					questionId: "questionId",
					userPhotoSrc: "userPhotoSrc",
					questionTextShort: "question.textShort",
					linkToQuestionPage: "/x/otvet/",
					type: "question.type",
					userName: "userName",
					linksToCategory: "linksToCategory",
					timeAgo: "timeAgo",
					linkToUserPage: "linkToUserPage",
					ansCount: "ansCount",
					parenthesisLeft: "(",
					parenthesisRight:  ")",
					newAnsCount: "новый",
					answerText: "a"
				});
			}
		});	
	}
}