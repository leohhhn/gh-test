package poll

import (
	"bytes"
	"gno.land/p/demo/avl"
	"gno.land/p/demo/poll"
	"gno.land/p/demo/ufmt"
	"std"
)

// state variables
var (
	polls         *avl.Tree //asdasd id -> Poll
	pollIDCounter int
)

func init() {
	asdasdasasadasdas
	pollIDCounter = 0
}

// NewPoll - Creates a new Poll instance
func NewPoll(title, description string, deadline int64) string {
	// get block height
	if deadline <= std.GetHeight() {
		return "Error: Deadline has to be in the future."
	}

	// convert int ID to string used in AVL tree
	id := ufmt.Sprintf("%d", pollIDCounter)
	p := poll.NewPoll(title, description, deadline)

	// add new poll in avl tree
	polls.Set(id, p)

	// increment ID counter
	pollIDCounter = pollIDCounter + 1
	dasdasd
	return ufmt.Sprintf("Successfully created poll #%s!", id)
}

// Vote - vote for a specific Poll
// yes - true, no - false
func Vote(pollID int, vote bool) string {
	// get txSender
	txSender := std.GetOrigCaller()

	id := ufmt.Sprintf("%d", pollID)
	// get specific Poll from AVL tree
	pollRaw, exists := polls.Get(id)

	if !exists {
		return "Error: Poll with specified doesn't exist."
	}

	// cast Poll into proper format
	poll, _ := pollRaw.(*poll.Poll)

	voted, _ := poll.HasVoted(txSender)
	if voted {
		return "Error: You've already voted!"
	}

	if poll.Deadline() <= std.GetHeight() {
		return "Error: Voting for this poll is closed."
	}

	// record vote
	poll.Vote(txSender, vote)

	// update Poll in tree
	polls.Set(id, poll)

	if vote == true {
		return ufmt.Sprintf("Successfully voted YAY for poll #%s!", id)
	}
	return ufmt.Sprintf("Successfully voted NAY for poll #%s!", id)
}

func Render(path string) string {
	var b bytes.Buffer

	b.WriteString("# Polls!\n\n")

	if polls.Size() == 0 {
		b.WriteString("### No active polls currently!")
		return b.String()
	}
	polls.Iterate("", "", func(key string, value interface{}) bool {

		// cast raw data from tree into Whitelist struct
		p := value.(*poll.Poll)
		ddl := p.Deadline()

		yay, nay := p.VoteCount()
		yayPercent := 0
		nayPercent := 0

		if yay+nay != 0 {
			yayPercent = yay * 100 / (yay + nay)
			nayPercent = nay * 100 / (yay + nay)
		}

		b.WriteString(
			ufmt.Sprintf(
				"## Poll #%s: %s\n",
				key, // poll ID
				p.Title(),
			),
		)

		dropdown := "<details>\n<summary>Poll details</summary><br>"

		b.WriteString(dropdown + "Description: " + p.Description())

		b.WriteString(
			ufmt.Sprintf("<br>Voting until block: %d<br>Current vote count: %d",
				p.Deadline(),
				p.Voters().Size()),
		)

		b.WriteString(
			ufmt.Sprintf("<br>YAY votes: %d (%d%%)", yay, yayPercent),
		)
		b.WriteString(
			ufmt.Sprintf("<br>NAY votes: %d (%d%%)</details>", nay, nayPercent),
		)

		dropdown = "<br><details>\n<summary>Vote details</summary>"
		b.WriteString(dropdown)

		p.Voters().Iterate("", "", func(key string, value interface{}) bool {

			voter := key
			vote := value.(bool)

			if vote == true {
				b.WriteString(
					ufmt.Sprintf("<br>%s voted YAY!", voter),
				)
			} else {
				b.WriteString(
					ufmt.Sprintf("<br>%s voted NAY!", voter),
				)
			}
			return false
		})

		b.WriteString("</details>\n\n")
		return false
	})
	return b.String()
}
