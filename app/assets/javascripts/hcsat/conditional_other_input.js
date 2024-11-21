class HCSATCheckboxes {
    initializeConditionalOtherInput(checkBoxId, revealContainerId) {
        // Reveal 'other' text input when 'other' checkbox is checked
        const checkbox = document.getElementById(checkBoxId)
        const revealContainer = document.getElementById(revealContainerId)

        // initially hide for js users
        revealContainer.classList.add('hidden')
        
        checkbox.addEventListener('change', async (event) => {
            if (checkbox.checked) {
                revealContainer.classList.remove('hidden')
            }
            else {
                revealContainer.classList.add('hidden')
            }
        })
    }

    initialiseExclusiveCheckBox(exclusiveCheckBoxId, conditionalRevealContainerId) {
        // If a user checks the exclusive 'no issues' checkbox, uncheck all other checkboxes and hide other text input
        // If a user checks another checkbox, uncheck the 'no issues' checkbox
        const exclusiveCheckBox = document.getElementById(exclusiveCheckBoxId)
        const conditionalRevealContainer = document.getElementById(conditionalRevealContainerId)

        exclusiveCheckBox.dataset.behaviour = 'exclusive'
        const sharedCheckboxName = exclusiveCheckBox.getAttribute("name");
        const allCheckboxesNodeList = document.getElementsByName(sharedCheckboxName)
        const allCheckboxesArray = Array.prototype.slice.call(allCheckboxesNodeList, 0);

        const nonExclusiveCheckboxes = allCheckboxesArray.filter((checkbox) => checkbox.dataset.behaviour != 'exclusive')

        for ( let i=0; i < nonExclusiveCheckboxes.length; i++ ) {
            nonExclusiveCheckboxes[i].addEventListener('change', async (event) => {
                if (nonExclusiveCheckboxes[i].checked) {
                    exclusiveCheckBox.checked = false
                }
            })
        }
        exclusiveCheckBox.addEventListener('change', async (event) => {
            if (exclusiveCheckBox.checked) {
                for ( let i=0; i < nonExclusiveCheckboxes.length; i++ ) {
                    nonExclusiveCheckboxes[i].checked = false;
                }
                if (!(conditionalRevealContainer.classList.contains('hidden'))){
                    conditionalRevealContainer.classList.add('hidden')
                }
            }
        })

    }
}

document.addEventListener('DOMContentLoaded', () => {
    HCSATCheckboxes = new HCSATCheckboxes();
    HCSATCheckboxes.initializeConditionalOtherInput('feedback_experienced_issues_other','conditional_reveal_container')
    HCSATCheckboxes.initialiseExclusiveCheckBox('feedback_experienced_issues_no_issue', 'conditional_reveal_container')
});