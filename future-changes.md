# Future Changes Document.&#x20;

In this document you will find a list of potential future changes we will want to make. Your goal is to methodically work through these 1 by 1. Starting at the top most unchecked task. Before tackling any of them you need to make sure you do the following:

* Systematically Work through the codebase to find the correct files that need editing. Once you are 90% sure you will deploy a subagent with no context of this and ask them to do the same task with no techincal details provided to it. This subagent will need to respond back with what files need to be changed, which you can cross reference with what you already chose. If the subagents respective suggested changes are different to yours you should work out why, and who is actually correct from the perspective of a senior iOS Developer.&#x20;
* Once the correct files have been identified you should do appropriate web searches and use the context7 MCP server to find appropriate documentation. When searching, mention the language we are using, the current achitecture, and the issue or question you have.&#x20;

***

### List of future upgrades

* [ ] We want to move the models tab pane (I think it's call view/pane), app permissions pane and the audio input pane. We want to move all of those to underneath the settings pane, but we want to have tabs at the top of the settings pane that categorise the settings correctly. Does this make sense? Could we run in to potential complicatios doing this?&#x20;







### Dont start these yet:

* [ ] Update the design of our Pill when using voice dictation
* [ ] Update the settings arrangement. We want things to be clean and easy to follow.&#x20;
* [ ] Update Power Mode naming. We don't want things to seem so gross, instead we want it to be more fluid and aligning with our beautiful Ember voice design.
* [ ] Remove the second recorder style for notch recorder. We don't need it for now. We just want to hide the option to change it to notch recorder, but we want to keep the code there just in case we want to reinstate it in the future.
* [ ] Add heading to the Transcribe Audio Tab.&#x20;
* [ ] Add heading to the Enhancement Tab and History Tab
* [ ] Fix Header on Models tab to align correctly, like the Audio Input and Dictionary Settings tabs.

