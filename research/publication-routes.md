# Publication and preservation routes

Checked 9 November 2026 (America/Los_Angeles) against official sources. This is route planning, not a claim that any submission, deposit, indexing or acceptance has occurred. The user's current request authorizes publishing the new verified work; a deferral concerning an earlier Hoggar paper does not control this new artifact.

## Publication package

Before depositing, complete the proof and executable evidence, build and visually inspect the PDF, and freeze a tagged source release. Keep the title, author, affiliation, ORCID, date, version, license, abstract and related identifiers consistent. Disclose the actual AI contribution accurately; do not describe AI tests as human peer review. The paper is a theoretical research article with a literature comparison, not a statistical meta-analysis of pooled experiments. Keep software, paper and data licensing distinct when appropriate.

## Zenodo: public preprint and reproducible artifact

**Eligibility is unresolved for this artifact.** Zenodo's current depositor policy requires research conducted by the listed human authors. It treats AI-originated core ideas or arguments without the uploader's own research engagement as an adverse indicator; accountable review of generated code and verification of literature claims are among its acceptable examples. It also expects substantive AI disclosure, prohibits AI authorship, and distinguishes documented simulations from fabricated observations. The present session establishes human direction and extensive automated verification; it does not establish the named author's personal critical engagement or validation. Automated Lean and numerical checks do not supply that missing fact. Do not infer eligibility solely from a broad instruction to publish. The author must review the actual work and document their substantive research role; if the fit remains uncertain, obtain clarification through Zenodo's ordinary support route before depositing. This finding comes from the current policy, not a deferral inherited from another project. [Official depositor AI policy](https://support.zenodo.org/help/en-gb/13-policies/227-what-is-your-usage-policy-for-generative-ai-for-depositors), [unsuitable content](https://support.zenodo.org/help/en-gb/2-content/141-what-content-is-not-suitable-for-zenodo).

Once eligibility is established, create a new upload using the authenticated account, upload the final PDF and source/certificate archive, describe the work as a preprint, include author/ORCID and the repository release relation, and reserve a DOI if it must appear in the PDF before publication. Preview and publish, then verify the public record and download hashes. A reserved DOI is not registered until publication. Avoid creating a second DOI for the same object if it already has one; a distinct software artifact can have its own identifier linked to the paper. [Official upload workflow](https://help.zenodo.org/docs/deposit/create-new-upload/), [DOI rules](https://help.zenodo.org/docs/deposit/describe-records/reserve-doi/).

Zenodo's current upload guide and quick-start page disagree about the exact period for file edits after publication. Treat the deposited files as fixed and use a versioned correction rather than relying on later replacement. Neither a DOI nor deposition constitutes peer review.

## arXiv: author submission and moderation

Prepare a self-contained LaTeX source bundle with bibliography and figures, its compiled PDF, abstract and accurate category metadata (quant-ph is the natural first candidate). Registered-author access and category endorsement may be needed. The submitting author should inspect the compiled result and make the required author/license declarations. arXiv expects author self-submission; proxy submissions have a separate policy. Do not claim a registered identity, endorsement, author approval or proxy status without evidence. Actual posting remains subject to moderation. [Submission overview](https://info.arxiv.org/help/submit/index.html), [endorsement](https://info.arxiv.org/help/endorsement.html), [submission agreement](https://info.arxiv.org/help/policies/submission_agreement.html), [proxy policy](https://info.arxiv.org/help/third_party_submission.html).

This route does not impose a blanket prohibition on AI-assisted mathematical research. The inspected conduct and submission rules require honest representation and author responsibility. Do not extrapolate social-media reports of policies to an unsupported claim that all AI-assisted submissions are barred. [Official code of conduct](https://info.arxiv.org/help/policies/code_of_conduct.html).

## Journal of Physics A: submission for editorial and peer review

Prepare the manuscript, cover letter, data-availability statement, research/AI disclosure and evidence links using the journal's current instructions. Select the journal from IOP's official submission directory, then use the linked manuscript portal. The journal requires a significant original correct mathematical-physics contribution; formal verification alone does not guarantee acceptance. [Journal scope and article types](https://publishingsupport.iopscience.iop.org/journals/journal-of-physics-a-mathematical-and-theoretical/about-journal-physics-mathematical-theoretical/), [official submission links](https://publishingsupport.iopscience.iop.org/questions/instructions-specific-journals/).

IOP's current AI policy allows disclosed research assistance, code, simulation, analysis and generated text, but authors must critically revise generated text and validate outputs. A separate disclosure belongs in Acknowledgements; research use also belongs in Methods. Citation sources must be checked against the originals. The final submission must truthfully reflect the author's own validation and approval; an agent cannot assert that a human performed review which has not occurred. [AI policy](https://publishingsupport.iopscience.iop.org/questions/generative-ai-tools/), [author submission responsibilities](https://publishingsupport.iopscience.iop.org/publishing-support/authors/authoring-for-journals/submit-journal-article/).

## Google Scholar: discoverable hosting, then indexing

Google Scholar is an index, not a manuscript publisher. Publish an openly fetchable PDF, a stable scholarly landing page and a publications-page link. The PDF needs a prominent title, author line and references. Include machine-readable title, author, date and PDF URL metadata on the landing page. Check public crawl access and subsequently search by exact title; distinguish a successful public deployment from actual indexing. Scholar describes a usual discovery period of weeks, not instant inclusion. [Official inclusion requirements](https://scholar.google.com/intl/en/scholar/inclusion.html).

## ORCID: research-output metadata

After the DOI resolves, use the author's authenticated ORCID record, Works -> Add -> DOI, retrieve the record, check imported fields and set the intended visibility. If DOI import is unavailable, use a BibTeX import or manual work entry. This adds a record to the author's profile; it is not a new paper publication or quality certification. [Official add-work guide](https://support.orcid.org/hc/en-us/articles/360006973133-Add-works-to-your-ORCID-record), [DOI import](https://support.orcid.org/hc/en-us/articles/360022298153-Add-works-using-an-identifier).

## OpenAIRE: repository aggregation and discovery

Use a connected repository such as Zenodo with accurate metadata and persistent identifiers, then verify the work in OpenAIRE Explore after ingestion. OpenAIRE describes itself as infrastructure harvesting connected data providers rather than a direct journal publisher. Do not invent EU funding or project metadata for a self-funded artifact. The official FAQ was available through search but direct fetching returned 403 during this audit, so timing for this particular record remains unverified. [Official FAQ](https://www.openaire.eu/faqs).

## Software Heritage: preserve source revision

Once the GitHub repository and desired commit are public, request a Save Code Now visit for its Git origin URL. Follow the request through successful ingestion and record the resulting snapshot/revision SWHID. A queued request is not yet a preserved snapshot. The service archives source history; it does not peer-review the manuscript. Official documentation describes save requests, validation, scheduling and pending/rejected states; some user documentation endpoints returned Anubis access denial during this read-only audit. Use the ordinary authenticated/browser flow if needed, without bypassing controls. [Official Save Code Now overview](https://www.softwareheritage.org/2019/01/10/save_code_now/), [documented request lifecycle](https://docs.softwareheritage.org/devel/apidoc/swh.web.save_code_now.origin_save.html).

## Internet Archive: paper files and web snapshot

For the paper, log into the authorized account, create a new item, upload the final PDF plus permitted supporting files, and fill title, creator, description, date, license and related DOI/repository links. Verify the item and actual files after processing. Separately request a Wayback snapshot of the public landing page and PDF if available. A captured page and a hosted file item are distinct preservation outputs. [Official upload guide](https://help.archive.org/help/uploading-a-basic-guide/).

## Evidence to retain

For each route, retain the exact files/hashes and observed state: local package, authenticated draft, submission receipt, public deposit, indexed record, accepted manuscript, or completed archive snapshot. Use the actual identifier or receipt; do not substitute a prepared package, simulated workflow or pending request for a completed external publication.
