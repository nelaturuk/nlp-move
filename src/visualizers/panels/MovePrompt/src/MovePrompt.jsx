import React, { useState, useEffect } from 'react';
import { Button, Container } from '@material-ui/core';
import AceEditor from "react-ace";

import "ace-builds/src-noconflict/mode-rust";
import "ace-builds/src-noconflict/theme-monokai";
//import { Configuration, OpenAIApi } from "openai";


const MovePrompt = ({ gmeClient, initialState }) => {

    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [code, setCode] = useState("// Write your code here");

    // useEffect(() => {
    //     // const configuration = new Configuration({
    //     //     organization: "org-yHpRUkK9kZsGJno9i2IbJlMw",
    //     //     apiKey: "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",
    //     // });

    //     // const openai = new OpenAIApi(configuration);
    // }, [])

    
    // const response = await openai.listEngines();

    const renderContent = () => (
        error ? <h3> {error} </h3> :
            <Container>
                <h2 className="center"> Move Prompt </h2>
                 
                
            </Container>
    );

    return (
        loading ? <h2> Loading... </h2> : renderContent()
    );
}

export default MovePrompt;
