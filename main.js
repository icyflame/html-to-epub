const helpText = `Example: node main.js input-file output-file output-metdata-file [debug] [text-output-file]

  input-file: HTML file containing the input markup. Required.
  output-file: HTML file containing the output markup (processed using readability and DOMpurify). Required.
  output-metadata-file: YAML formatted file with metadata about the content (title, author, language). Required.
  debug: Set this to "yes" to print debug logs. Optional. Default: no.
  output-text-file: Set this to write out the text content of the article. Optional.
`

if (process.argv.length < 5) {
	console.error(`ERROR: Must provide input file as argument.

${helpText}
`);
	process.exit(1);
}

const inputFile = process.argv[2];
const outputFile = process.argv[3];
const outputFileMetadata = process.argv[4];
if (!outputFileMetadata.endsWith(".xml")) {
	console.error(`ERROR: Metdata filename (${outputFileMetadata}) must have the .xml extension.

${helpText}
`);
	process.exit(1);
}

const debug = process.argv.length >= 6 && process.argv[5] === 'yes';
const outputTextFile = process.argv.length >= 7 ? process.argv[6] : '';

const { Readability } = require('@mozilla/readability');
const { JSDOM } = require('jsdom');
const fs = require('fs');
const DOMPurify = require('isomorphic-dompurify');
fs.readFile(inputFile, 'utf8', (err, data) => {
	if (err) {
		throw err;
	} else {
		console.log('read input file')
	}

	let doc = new JSDOM(data, {
		contentType: 'text/html',
	});
	let reader = new Readability(doc.window.document);
	let article = reader.parse();
	if (outputTextFile !== '') {
		fs.writeFile(outputTextFile, article.textContent, 'utf8', (err) => {
			if (err) {
				throw err;
			} else {
				console.log('written to output text file');
			}
		});
	}
	const metadata = `<dc:title>${article.title}</dc:title>
<dc:publisher>${article.siteName}</dc:publisher>
<dc:creator>${article.byline}</dc:creator>
<dc:description>${article.excerpt}</dc:description>
<dc:language>${article.lang}</dc:language>`;

	if(debug) console.log(require('util').inspect(article));

	let clean = DOMPurify.sanitize(article.content);

	fs.writeFile(outputFile, clean, 'utf8', (err) => {
		if (err) {
			throw err;
		} else {
			console.log('written to output file');
		}
	});

	fs.writeFile(outputFileMetadata, metadata, 'utf8', (err) => {
		if (err) {
			throw err;
		} else {
			console.log('written to output metdata file');
		}
	})
});
